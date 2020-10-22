const rescue = require('express-rescue');
const Sequelize = require('sequelize');
const CustomError = require('../services/errorScheme');
const { postValidation } = require('../services/joiValidation');
const { Posts } = require('../models');
const { Users } = require('../models');

const { Op } = Sequelize;

const createPost = rescue(async (req, res) => {
  const { body: { title, content }, user } = req;
  const { id: userId } = user;
  return postValidation.validateAsync({ title, content })
    .then(() => Posts.create({ title, content, userId })
      .then((data) => res.status(201).json(data.dataValues))
      .catch((err) => {
        throw new CustomError({ message: err.message, code: err.code });
      }))
    .catch((err) => {
      throw new CustomError({ message: err.message, code: 400 });
    });
});

const getPosts = rescue(async (req, res) => {
  const { id: postId } = req.params ? req.params : null;
  const attributes = { include: [{ model: Users, as: 'user', attributes: { exclude: ['password'] } }] };
  const posts = await Posts
    .findAll(
      (postId
        ? { where: { id: postId }, ...attributes }
        : { ...attributes }
      ),
    )
    .then((data) => data)
    .catch((err) => {
      throw new CustomError({ message: err.message, code: 500 });
    });

  if (postId && posts.length === 0) throw new CustomError({ message: 'Post não existe', code: 404 });

  // const postData = posts.map((post) => post.dataValues);

  // const fetchUserData = postData.map(
  //   async ({ id, published, updated, title, content, userId }) => {
  //     const userData = async () => Users.findOne(
  //       { where: { id: userId } },
  //     );
  //     const { displayName, email, image } = await userData()
  //       .catch((err) => {
  //         throw new CustomError({ message: err.message, code: 500 });
  //       });
  //     const user = { id: userId, displayName, email, image };
  //     const newPost = { id, published, updated, title, content, user };
  //     return newPost;
  //   },
  // );
  // const postWithUserData = await Promise.all(fetchUserData).then((data) => data);
  res.status(200).json(posts.length === 1
    ? posts[0]
    : posts);
});

const updatePost = rescue(async (req, res) => {
  const { body: { title, content }, user } = req;
  const { id: userId } = user;
  const { id: postId } = req.params;

  const { userId: currentAuthorId } = await Posts.findOne(
    { where: { id: postId } },
  ).then((data) => data.dataValues);

  if (Number(currentAuthorId) !== Number(userId)) throw new CustomError({ message: 'Só o autor pode editar posts.', code: 401 });

  return postValidation.validateAsync({ title, content })
    .then(() => Posts.update(
      { title, content },
      { where: { id: postId } },
    )
      .then(() => res.status(200).json({ message: 'Post atualizado com sucesso.' }))
      .catch((err) => {
        throw new CustomError({ message: err.message, code: err.code });
      }))
    .catch((err) => {
      throw new CustomError({ message: err.message, code: 400 });
    });
});

const searchPosts = rescue(async (req, res) => {
  const { query: { q } } = req;

  const posts = await Posts.findAll(
    {
      where: {
        [Op.or]: [
          { title: { [Op.like]: `${q}%` } },
          { content: { [Op.like]: `${q}%` } },
        ],
      },
    },
  ).then((data) => data.map(({ dataValues }) => dataValues))
    .catch((err) => {
      throw new CustomError({ message: err.message, code: 500 });
    });

  return res.status(200).json(posts);
});

const deletePosts = rescue(async (req, res) => {
  const { id: postId } = req.params ? req.params : null;
  if (!postId) throw new CustomError({ message: 'Nenhum ID foi especificado', code: 400 });

  const posts = await Posts
    .findAll({ where: { id: postId } }).then((data) => data)
    .catch((err) => {
      throw new CustomError({ message: err.message, code: 500 });
    });

  if (postId && posts.length === 0) throw new CustomError({ message: 'Nenhum post encontrado', code: 404 });

  const { user: { id: userId } } = req;

  const { userId: currentAuthorId } = await Posts.findOne(
    { where: { id: postId } },
  ).then((data) => data.dataValues);

  if (Number(currentAuthorId) !== Number(userId)) throw new CustomError({ message: 'Só o autor pode deletar posts.', code: 401 });

  await Posts.destroy({ where: { id: postId } })
    .then(() => res.status(204).json({ message: 'Post deletado com sucesso' }))
    .catch((err) => {
      throw new CustomError({ message: err.message, code: err.code });
    });
});

module.exports = {
  createPost,
  getPosts,
  updatePost,
  searchPosts,
  deletePosts,
};

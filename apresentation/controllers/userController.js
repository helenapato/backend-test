const jwt = require('jsonwebtoken');
const rescue = require('express-rescue');

const SECRET = 'UNEXPECTED THIS';
const jwtConfig = { algorithm: 'HS256', expiresIn: '1h' };
const regex = /^[a-z0-9.]+@[a-z0-9]+\.[a-z]+\.([a-z]+)?$/i;
const model = require('../../models');

const createUser = (service) => rescue(async (req, res) => {
  const { email, displayName, password, image } = req.body;

  if (displayName.length < 8) return res.status(400).json({ message: '"displayName" length must be at least 8 characters long' });
  if (password.length < 6) return res.status(400).json({ message: '"password" length must be 6 characters long' });
  if (!password) return res.status(400).json({ message: '"password" is required' });
  if (!email) return res.status(400).json({ message: '"email" is required' });
  if (regex.test(email)) return res.status(400).json({ message: '"email" must be a valid email' });

  const verifyUser = model.User.findAll({ where: { email } });
  console.log('aqui', verifyUser);
  if (verifyUser.length > 0) return res.status(409).json({ message: 'Usuário já existe' });

  const userCreate = await service.createUser(email, displayName, password, image);

  const token = jwt.sign({ userCreate }, SECRET, jwtConfig);

  return res.status(201).json({ token });
});

const loginUser = rescue(async (req, res) => {
  const { email, password } = req.body;
  const { token } = req.token;

  if (!email || !password) return res.status(400).json({ message: 'Campos inválidos' });

  return res.status(200).json(token);
});

const getUsers = (service) => rescue(async (req, res) => {
  console.log(req, 'brasil');
  const allUsers = await service.getAllUser();
  return res.status(200).json(allUsers);
});

const getUserById = (service) => rescue(async (req, res) => {
  const { id } = req.params;
  return service.getUserById(id).then((user) => {
    if (!user) return res.status(404).json({ message: 'Usuario não encontrado' });
    return res.status(200).json(user);
  });
});

const deleteUser = (service) => rescue(async (req, res) => {
  const { id } = req.params;
  // pegar o id pelo token e passar pro delete user

  return service.deleteUser(id)
    .then(() => res.status(204).send({ message: 'excluido com sucesso' })
      .catch((e) => {
        console.error(e.message);
        res.status(500).send({ message: 'deu ruim' });
      }));
});

const getUserController = (service) => ({
  createUser: createUser(service),
  loginUser,
  getUsers: getUsers(service),
  getUserById: getUserById(service),
  deleteUser: deleteUser(service),
});

module.exports = { getUserController };

const express = require('express');
const bodyParser = require('body-parser');
const userController = require('./controllers/userController');
const postController = require('./controllers/postController');
const auth = require('./auth/authMiddleware');

const app = express();
app.use(bodyParser.json());

app.post('/user', userController.createNewUser);
app.post('/login', userController.userLogin);
app.get('/user/:id', auth, userController.getUserById);
app.get('/user', auth, userController.getAllUsers);
app.delete('/user/me', auth, userController.deleteSelfUser);
app.post('/post', auth, postController.createPost);
app.get('/post', auth, postController.getAllPosts);

app.listen(3000, () => console.log('ouvindo porta 3000!'));
// não remova esse endpoint, e para o avaliador funcionar
app.get('/', (request, response) => {
  response.send();
});

const { GenerateToken } = require('./JWT');
const { User } = require('../models');
const err = require('../errors');

const CreateUser = async (payload) => {
  const { displayName, email, password, image } = payload;

  //* Validações de parâmetros
  const NameErr = err.ErrHandler.VerifyNameLength(displayName, 8);
  const EmailErr = err.ErrHandler.VerifyEmail(email);
  const PassErr = err.ErrHandler.VerifyPassword(password, 6);

  if (NameErr) return NameErr;
  if (EmailErr) return EmailErr;
  if (PassErr) return PassErr;

  //* Validação de usuário duplicado
  const duplicateErr = await err.ErrHandler.VerifyDuplicate(email);
  if (duplicateErr) return duplicateErr;

  //* Passando nas validações é inserido no DB e gerado um token com a senha informada.
  await User.create({ displayName, email, password, image });
  const token = GenerateToken({ email, password });
  return { token };
};

module.exports = {
  CreateUser,
  /* UserLogin,
  GetUsers,
  GetUserById,
  DeleteUser, */
};
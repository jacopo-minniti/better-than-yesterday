module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    'eslint:recommended',
    'google',
  ],
  rules: {
    'indent': 'off',
    'quotes': [2, 'single', {'avoidEscape': true}],
    'eol-last': 0,
    'no-multiple-empty-lines': ['error', {'max': 1, 'maxEOF': 0}],
    'max-len': 'off',
  },
  parserOptions: {
    'parser': 'babel-eslint',
    'ecmaVersion': 2022,
  },
};

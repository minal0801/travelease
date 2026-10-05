const router = require('express').Router();
const { protect } = require('../middleware/authMiddleware');
const admin = require('../middleware/adminMiddleware');
module.exports = (c) => {
  router.get('/', c.list);
  router.get('/:id', c.get);
  router.post('/', protect, admin, c.create);
  router.put('/:id', protect, admin, c.update);
  router.delete('/:id', protect, admin, c.remove);
  return router;
};

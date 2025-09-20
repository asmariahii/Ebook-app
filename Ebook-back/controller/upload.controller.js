const multer = require('multer');
const path = require('path');

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    if (file.fieldname === 'cover') {
      cb(null, 'uploads/covers/');
    } else if (file.fieldname === 'pdf') {
      cb(null, 'uploads/pdfs/');
    }
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const fileFilter = (req, file, cb) => {
  if (file.fieldname === 'cover') {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed!'), false);
    }
  } else if (file.fieldname === 'pdf') {
    if (file.mimetype === 'application/pdf') {
      cb(null, true);
    } else {
      cb(new Error('Only PDF files are allowed!'), false);
    }
  }
};

const upload = multer({ 
  storage: storage,
  fileFilter: fileFilter,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB limit
});

exports.uploadCover = [
  upload.single('cover'),
  async (req, res) => {
    try {
      if (!req.file) {
        return res.status(400).json({ status: false, error: 'No image uploaded' });
      }
      
      const imageUrl = `/uploads/covers/${req.file.filename}`;
      
      res.status(200).json({ 
        status: true, 
        data: { url: imageUrl, filename: req.file.filename }
      });
    } catch (err) {
      console.error('Upload error:', err);
      res.status(500).json({ status: false, error: err.message });
    }
  }
];

exports.uploadPdf = [
  upload.single('pdf'),
  async (req, res) => {
    try {
      if (!req.file) {
        return res.status(400).json({ status: false, error: 'No PDF uploaded' });
      }
      
      const pdfUrl = `/uploads/pdfs/${req.file.filename}`;
      
      res.status(200).json({ 
        status: true, 
        data: { url: pdfUrl, filename: req.file.filename }
      });
    } catch (err) {
      console.error('Upload error:', err);
      res.status(500).json({ status: false, error: err.message });
    }
  }
];
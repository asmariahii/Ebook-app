const express = require("express");
const bodyParser = require("body-parser");
const UserRoute = require("./routes/user.router");
const bookRoutes = require("./routes/book.routes");
const { uploadCover, uploadPdf } = require("./routes/upload.routes");
const path = require("path");
const multer = require('multer');
const cors = require("cors");

const app = express();

// Ensure uploads directory exists
const fs = require('fs');
const uploadDir = 'uploads';
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir);
}

// Configure storage
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, uploadDir);
    },
    filename: function (req, file, cb) {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, uniqueSuffix + path.extname(file.originalname));
    }
});

// File filter - only allow images
const fileFilter = (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
        cb(null, true);
    } else {
        cb(new Error('Only image files are allowed!'), false);
    }
};

const upload = multer({ 
    storage: storage,
    limits: {
        fileSize: 5 * 1024 * 1024 // 5MB limit
    },
    fileFilter: fileFilter
});

// Middleware
app.use(bodyParser.json());
app.use(cors());

// Serve static files from uploads directory
app.use("/uploads", express.static(path.join(__dirname, "assets/images")));


// Mount your routes - PASS THE UPLOAD MIDDLEWARE
app.use("/auth", UserRoute(upload));
app.use("/books", bookRoutes);


app.post('/upload/cover', uploadCover);
app.post('/upload/pdf', uploadPdf);
// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ status: false, error: err.message });
});

module.exports = app;
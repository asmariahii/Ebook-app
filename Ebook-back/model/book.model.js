const mongoose = require("mongoose");

const bookSchema = new mongoose.Schema({
    title: {
        type: String,
        required: [true, "Book title is required"]
    },
    author: {
        type: String,
        required: [true, "Author name is required"]
    },
    description: {
        type: String,
        required: [true, "Description is required"]
    },
    cover: {
        type: String, // URL or path to image
        required: [true, "Cover image is required"]
    },
    file: {
        type: String, // URL or path to PDF/EPUB file
        required: [true, "Book file is required"]
    },
    isTrending: {
        type: Boolean,
        default: false
    }
}, { timestamps: true });

module.exports = mongoose.model("Book", bookSchema);

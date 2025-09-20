// Base URL of your Node.js server
const baseUrl = 'http://192.168.1.21:5000/';

// Auth endpoints
const register = "${baseUrl}auth/register";
const login = "${baseUrl}auth/login";

// Book endpoints
const booksUrl = "${baseUrl}books";        // GET all books / POST new book
const trendingBooksUrl = "${baseUrl}books/trending"; // GET trending books
const favoritesUrl = "${baseUrl}auth/favorites";
const favoritesRemoveUrl = "${baseUrl}auth/favorites/remove"; 
// Search endpoint
const searchUrl = "${baseUrl}books/search";
// PROFILE
const profileUrl = "${baseUrl}auth/profile";
const updateProfileUrl = "${baseUrl}auth/profile";


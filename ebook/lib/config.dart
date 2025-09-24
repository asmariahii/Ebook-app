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
const logoutUrl = "${baseUrl}auth/logout"; // POST logout

//ADMIN
const adminUsersUrl = "${baseUrl}auth/users";  // GET all users
const adminDeleteUserUrl = "${baseUrl}auth/users"; // DELETE user

const adminBooksUrl = "${baseUrl}books";  // GET all books (admin)
const adminAddBookUrl = "${baseUrl}books/add"; // POST new book (admin)
const adminDeleteBookUrl = "${baseUrl}books"; // DELETE book (admin)

const uploadCoverUrl = "${baseUrl}upload/cover";      // Upload book cover image
const uploadPdfUrl = "${baseUrl}upload/pdf";
const analyticsUrl = "${baseUrl}books/analytics"; 

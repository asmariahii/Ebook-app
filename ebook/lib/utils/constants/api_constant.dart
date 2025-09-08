//for emulator android
const url = 'http://10.0.2.2:5000/';
//for real device
//(cmd==>ipconfig ==>Carte réseau sans fil Wi-Fi :  Adresse IPv4: 172.16.137.108)
//const url = 'http://172.16.137.108:5000/';
//Auth
const register = "${url}auth/registration";
const login = "${url}auth/login";
//Todo
const storeTodo = "${url}todo/storeTodo";
const getTodo = "${url}todo/getUserTodoList";
const deleteTodoItem = "${url}todo/deleteTodo";

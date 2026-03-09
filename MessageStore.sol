contract MessageStore {
    string public message;

    function set(string _message) {
        message = _message;
    }
}

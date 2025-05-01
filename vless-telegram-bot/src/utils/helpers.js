module.exports = {
    validateUserInput: (input) => {
        const regex = /^[a-zA-Z0-9_]+$/;
        return regex.test(input);
    },

    generateUUID: () => {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
            const r = Math.random() * 16 | 0;
            const v = c === 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    },

    formatMessage: (message) => {
        return message.replace(/_/g, '\\_').replace(/\\/g, '\\\\');
    }
};
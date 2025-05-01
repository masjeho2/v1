const { v4: uuidv4 } = require('uuid');
const { exec } = require('child_process');
const TelegramBot = require('node-telegram-bot-api');
const bot = new TelegramBot(process.env.TELEGRAM_BOT_TOKEN, { polling: true });

const addVless = async (chatId, user) => {
    const message = `Please provide the following details to create a Vless account:\n1. Username\n2. Expiration (days)\n`;
    await bot.sendMessage(chatId, message);

    bot.onReplyToMessage(chatId, user.message_id, async (reply) => {
        const [username, expiration] = reply.text.split('\n').map(line => line.trim());
        const uuid = uuidv4();

        if (!username || !expiration) {
            return bot.sendMessage(chatId, 'Invalid input. Please provide both username and expiration days.');
        }

        exec(`bash /path/to/add-vless.sh ${username} ${uuid} ${expiration}`, (error, stdout, stderr) => {
            if (error) {
                return bot.sendMessage(chatId, `Error creating Vless account: ${stderr}`);
            }
            bot.sendMessage(chatId, `Vless account created successfully:\n${stdout}`);
        });
    });
};

module.exports = addVless;
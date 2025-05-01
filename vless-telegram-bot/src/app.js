const TelegramBot = require('node-telegram-bot-api');
const addVlessCommand = require('./commands/addVless');
require('dotenv').config();

const token = process.env.TELEGRAM_BOT_TOKEN;
const bot = new TelegramBot(token, { polling: true });

bot.onText(/\/start/, (msg) => {
    const chatId = msg.chat.id;
    bot.sendMessage(chatId, 'Welcome to the Vless Account Creator Bot! Use /addVless to create a new Vless account.');
});

bot.onText(/\/addVless/, (msg) => {
    const chatId = msg.chat.id;
    addVlessCommand(chatId, bot);
});

bot.on('message', (msg) => {
    const chatId = msg.chat.id;
    // Handle other messages or commands if necessary
});

console.log('Bot is running...');
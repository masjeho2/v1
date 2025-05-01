# Vless Telegram Bot

This project is a Telegram bot that facilitates the creation of Vless accounts. It allows users to easily add Vless accounts by interacting with the bot through commands.

## Project Structure

```
vless-telegram-bot
├── src
│   ├── app.js                # Entry point of the Telegram bot application
│   ├── commands
│   │   └── addVless.js       # Handles the /addVless command
│   └── utils
│       └── helpers.js        # Utility functions for the bot
├── package.json              # npm configuration file
├── .env                      # Environment variables for the bot
└── README.md                 # Documentation for the project
```

## Setup Instructions

1. **Clone the repository:**
   ```
   git clone <repository-url>
   cd vless-telegram-bot
   ```

2. **Install dependencies:**
   ```
   npm install
   ```

3. **Configure environment variables:**
   Create a `.env` file in the root directory and add your Telegram bot token:
   ```
   TELEGRAM_BOT_TOKEN=your_bot_token_here
   ```

4. **Run the bot:**
   ```
   node src/app.js
   ```

## Usage

- Start a chat with your bot on Telegram.
- Use the command `/addVless` to initiate the process of creating a Vless account.

## Command Descriptions

- **/addVless**: Prompts the user for the necessary information to create a Vless account, such as username and UUID.

## Contributing

Feel free to submit issues or pull requests to improve the bot's functionality or documentation.
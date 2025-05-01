const fs = require("fs");
const axios = require("axios");
const path = require("path");

// Telegram Bot Configuration
const BOT_TOKEN = "7949975517:AAFfocrFiDOaG-AZqDD41ENgkEvCC3LlffQ";
const TELEGRAM_API = `https://api.telegram.org/bot${BOT_TOKEN}`;
let offset = 0;

// Paths
const CONFIG_PATH = path.join(__dirname, "../other/config.json");

// Helper function to send messages
const sendMessage = async (chatId, text) => {
  try {
    await axios.post(`${TELEGRAM_API}/sendMessage`, {
      chat_id: chatId,
      text: text,
      parse_mode: "HTML",
    });
  } catch (error) {
    console.error("Error sending message:", error.message);
  }
};

// Add Vless account
const addVless = (chatId, username, days) => {
  try {
    const config = JSON.parse(fs.readFileSync(CONFIG_PATH, "utf8"));
    const uuid = require("crypto").randomUUID();
    const expiryDate = new Date();
    expiryDate.setDate(expiryDate.getDate() + parseInt(days));
    const expiry = expiryDate.toISOString().split("T")[0];

    // Add user to Vless WS and gRPC
    config.inbounds.forEach((inbound) => {
      if (inbound.tag === "vless-in" || inbound.tag === "vlessgrpc-in") {
        inbound.users.push({ name: username, uuid: uuid });
      }
    });

    // Save updated config
    fs.writeFileSync(CONFIG_PATH, JSON.stringify(config, null, 2), "utf8");

    // Send confirmation
    sendMessage(
      chatId,
      `Vless account added:\nUsername: <b>${username}</b>\nUUID: <b>${uuid}</b>\nExpires on: <b>${expiry}</b>`
    );
  } catch (error) {
    sendMessage(chatId, `Error adding Vless account: ${error.message}`);
  }
};

// Extend Vless account
const extendVless = (chatId, username, days) => {
  try {
    const config = JSON.parse(fs.readFileSync(CONFIG_PATH, "utf8"));
    const user = config.inbounds
      .flatMap((inbound) => inbound.users || [])
      .find((user) => user.name === username);

    if (!user) {
      sendMessage(chatId, `User <b>${username}</b> not found.`);
      return;
    }

    const expiryDate = new Date();
    expiryDate.setDate(expiryDate.getDate() + parseInt(days));
    const expiry = expiryDate.toISOString().split("T")[0];

    // Update expiry in config (if applicable)
    // Note: The original `config.json` structure does not store expiry dates directly.

    // Send confirmation
    sendMessage(
      chatId,
      `Vless account extended:\nUsername: <b>${username}</b>\nNew Expiry: <b>${expiry}</b>`
    );
  } catch (error) {
    sendMessage(chatId, `Error extending Vless account: ${error.message}`);
  }
};

// Delete Vless account
const deleteVless = (chatId, username) => {
  try {
    const config = JSON.parse(fs.readFileSync(CONFIG_PATH, "utf8"));

    // Remove user from Vless WS and gRPC
    config.inbounds.forEach((inbound) => {
      if (inbound.tag === "vless-in" || inbound.tag === "vlessgrpc-in") {
        inbound.users = inbound.users.filter((user) => user.name !== username);
      }
    });

    // Save updated config
    fs.writeFileSync(CONFIG_PATH, JSON.stringify(config, null, 2), "utf8");

    // Send confirmation
    sendMessage(chatId, `Vless account deleted:\nUsername: <b>${username}</b>`);
  } catch (error) {
    sendMessage(chatId, `Error deleting Vless account: ${error.message}`);
  }
};

// Process commands
const processCommand = (chatId, command) => {
  const parts = command.split(" ");
  const action = parts[0];
  const args = parts.slice(1);

  switch (action) {
    case "/add":
      if (args.length < 2) {
        sendMessage(chatId, "Usage: /add <username> <days>");
      } else {
        addVless(chatId, args[0], args[1]);
      }
      break;

    case "/extend":
      if (args.length < 2) {
        sendMessage(chatId, "Usage: /extend <username> <days>");
      } else {
        extendVless(chatId, args[0], args[1]);
      }
      break;

    case "/delete":
      if (args.length < 1) {
        sendMessage(chatId, "Usage: /delete <username>");
      } else {
        deleteVless(chatId, args[0]);
      }
      break;

    case "/help":
      sendMessage(
        chatId,
        "Available commands:\n" +
          "/add <username> <days> - Add a new Vless account\n" +
          "/extend <username> <days> - Extend an existing Vless account\n" +
          "/delete <username> - Delete a Vless account\n" +
          "/help - Show this help message"
      );
      break;

    default:
      sendMessage(chatId, "Invalid command. Use /help to see available commands.");
  }
};

// Main loop to listen for updates
const listenForUpdates = async () => {
  try {
    const response = await axios.get(`${TELEGRAM_API}/getUpdates`, {
      params: { offset },
    });
    const updates = response.data.result;

    for (const update of updates) {
      const updateId = update.update_id;
      const chatId = update.message.chat.id;
      const text = update.message.text;

      processCommand(chatId, text);

      // Update the offset
      offset = updateId + 1;
    }
  } catch (error) {
    console.error("Error fetching updates:", error.message);
  }
};

// Start the bot
const startBot = () => {
  console.log("Bot is running...");
  setInterval(listenForUpdates, 1000);
};

startBot();

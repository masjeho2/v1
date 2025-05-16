const fs = require("fs");
const path = require("path");
const TelegramBot = require("node-telegram-bot-api");

// Replace with your bot token
const BOT_TOKEN = "7765335072:AAG_Xox--nhrRUyqUbRvUkCv7IdJ3cGzFHA";
const bot = new TelegramBot(BOT_TOKEN, { polling: true });

// File paths
const xrayConfigPath = "/usr/local/etc/xray/config.json";
// File path for expiration data
const expClientsPath = "/usr/local/etc/xray/exp_clients.json";

// Allowed Telegram IDs
const ALLOWED_IDS = [1658354197]; // Replace with actual Telegram user IDs

// Helper to read and write config.json
const readConfig = () => {
  try {
    let data = fs.readFileSync(xrayConfigPath, "utf8");
    // Remove lines starting with '#' (comments) and trim whitespace
    data = data
      .split("\n")
      .filter((line) => !line.trim().startsWith("#"))
      .join("\n");
    return JSON.parse(data);
  } catch (err) {
    throw new Error(`Error reading config.json: ${err.message}`);
  }
};

const writeConfig = (config) => {
  try {
    fs.writeFileSync(xrayConfigPath, JSON.stringify(config, null, 2), "utf8");
  } catch (err) {
    throw new Error(`Error writing config.json: ${err.message}`);
  }
};

// Helper to read and write expiration data
const readExpClients = () => {
  try {
    if (!fs.existsSync(expClientsPath)) {
      fs.writeFileSync(expClientsPath, JSON.stringify({}, null, 2), "utf8");
    }
    return JSON.parse(fs.readFileSync(expClientsPath, "utf8"));
  } catch (err) {
    throw new Error(`Error reading exp_clients.json: ${err.message}`);
  }
};

const writeExpClients = (data) => {
  try {
    fs.writeFileSync(expClientsPath, JSON.stringify(data, null, 2), "utf8");
  } catch (err) {
    throw new Error(`Error writing exp_clients.json: ${err.message}`);
  }
};

// Middleware to check Telegram ID
const isAuthorized = (msg) => {
  if (!ALLOWED_IDS.includes(msg.from.id)) {
    bot.sendMessage(msg.chat.id, "You are not authorized to use this bot.");
    return false;
  }
  return true;
};

// Commands
bot.onText(/\/start/, (msg) => {
  if (!isAuthorized(msg)) return;
  const chatId = msg.chat.id;
  bot.sendMessage(chatId, "Welcome! Use /help to see available commands.");
});

bot.onText(/\/help/, (msg) => {
  if (!isAuthorized(msg)) return;
  const chatId = msg.chat.id;
  bot.sendMessage(chatId, `
Available commands:
/start - Start the bot
/help - Show this help message
/view_config - View the current Xray config.json
/add_vmess - Add a Vmess account
/extend_vmess - Extend a Vmess account
/delete_vmess - Delete a Vmess account
/check_vmess - Check Vmess user logins
/add_vless - Add a Vless account
/extend_vless - Extend a Vless account
/delete_vless - Delete a Vless account
/check_vless - Check Vless user logins
/add_trojan - Add a Trojan account
/extend_trojan - Extend a Trojan account
/delete_trojan - Delete a Trojan account
/check_trojan - Check Trojan user logins
`);
});

bot.onText(/\/view_config/, (msg) => {
  if (!isAuthorized(msg)) return;
  const chatId = msg.chat.id;
  try {
    const config = readConfig();
    bot.sendMessage(chatId, `Current config.json:\n\`\`\`\n${JSON.stringify(config, null, 2)}\n\`\`\``, {
      parse_mode: "Markdown",
    });
  } catch (err) {
    bot.sendMessage(chatId, err.message);
  }
});

// Add Vmess account
bot.onText(/\/add_vmess/, (msg) => {
  const chatId = msg.chat.id;
  bot.sendMessage(chatId, "Enter username for the new Vmess account:");
  bot.once("message", (response) => {
    const username = response.text;
    bot.sendMessage(chatId, "Enter expiration days:");
    bot.once("message", (response) => {
      const days = parseInt(response.text, 10);
      try {
        const config = readConfig();
        const expClients = readExpClients();
        const uuid = require("crypto").randomUUID();
        const expirationDate = new Date();
        expirationDate.setDate(expirationDate.getDate() + days);

        const newAccount = {
          id: uuid,
          alterId: 0,
          email: username,
        };

        config.inbounds[0].settings.clients.push(newAccount);
        expClients[username] = expirationDate.toISOString().split("T")[0];

        writeConfig(config);
        writeExpClients(expClients);

        bot.sendMessage(chatId, `Vmess account added:\nUsername: ${username}\nUUID: ${uuid}\nExpires on: ${expClients[username]}`);
      } catch (err) {
        bot.sendMessage(chatId, err.message);
      }
    });
  });
});

// Extend Vmess account
bot.onText(/\/extend_vmess/, (msg) => {
  const chatId = msg.chat.id;
  bot.sendMessage(chatId, "Enter username to extend:");
  bot.once("message", (response) => {
    const username = response.text;
    bot.sendMessage(chatId, "Enter additional days:");
    bot.once("message", (response) => {
      const days = parseInt(response.text, 10);
      try {
        const expClients = readExpClients();
        if (!expClients[username]) {
          bot.sendMessage(chatId, `No Vmess account found for username: ${username}`);
          return;
        }

        const currentExpiration = new Date(expClients[username]);
        currentExpiration.setDate(currentExpiration.getDate() + days);
        expClients[username] = currentExpiration.toISOString().split("T")[0];

        writeExpClients(expClients);

        bot.sendMessage(chatId, `Vmess account extended:\nUsername: ${username}\nNew expiration: ${expClients[username]}`);
      } catch (err) {
        bot.sendMessage(chatId, err.message);
      }
    });
  });
});

// Delete Vmess account
bot.onText(/\/delete_vmess/, (msg) => {
  const chatId = msg.chat.id;
  bot.sendMessage(chatId, "Enter username to delete:");
  bot.once("message", (response) => {
    const username = response.text;
    try {
      const config = readConfig();
      const expClients = readExpClients();

      const index = config.inbounds[0].settings.clients.findIndex((c) => c.email === username);
      if (index === -1) {
        bot.sendMessage(chatId, `No Vmess account found for username: ${username}`);
        return;
      }

      config.inbounds[0].settings.clients.splice(index, 1);
      delete expClients[username];

      writeConfig(config);
      writeExpClients(expClients);

      bot.sendMessage(chatId, `Vmess account deleted:\nUsername: ${username}`);
    } catch (err) {
      bot.sendMessage(chatId, err.message);
    }
  });
});

// Check Vmess user logins
bot.onText(/\/check_vmess/, (msg) => {
  const chatId = msg.chat.id;
  try {
    const logPath = "/var/log/xray/access.log";
    const logs = fs.readFileSync(logPath, "utf8");
    const users = logs.match(/email":"(.*?)"/g).map((match) => match.split('"')[1]);
    const uniqueUsers = [...new Set(users)];
    bot.sendMessage(chatId, `Active Vmess users:\n${uniqueUsers.join("\n")}`);
  } catch (err) {
    bot.sendMessage(chatId, `Error reading logs: ${err.message}`);
  }
});

// Vless commands
bot.onText(/\/add_vless/, (msg) => {
  const chatId = msg.chat.id;
  bot.sendMessage(chatId, "Enter username for the new Vless account:");
  bot.once("message", (response) => {
    const username = response.text;
    bot.sendMessage(chatId, "Enter expiration days:");
    bot.once("message", (response) => {
      const days = parseInt(response.text, 10);
      try {
        const config = readConfig();
        const uuid = require("crypto").randomUUID();
        const expirationDate = new Date();
        expirationDate.setDate(expirationDate.getDate() + days);
        const newAccount = {
          id: uuid,
          email: username,
        };
        config.inbounds[1].settings.clients.push(newAccount);
        writeConfig(config);
        bot.sendMessage(chatId, `Vless account added:\nUsername: ${username}\nUUID: ${uuid}\nExpires on: ${expirationDate.toISOString().split("T")[0]}`);
      } catch (err) {
        bot.sendMessage(chatId, err.message);
      }
    });
  });
});

bot.onText(/\/extend_vless/, (msg) => {
  const chatId = msg.chat.id;
  bot.sendMessage(chatId, "Enter username to extend:");
  bot.once("message", (response) => {
    const username = response.text;
    bot.sendMessage(chatId, "Enter additional days:");
    bot.once("message", (response) => {
      const days = parseInt(response.text, 10);
      try {
        const expClients = readExpClients();
        if (!expClients[username]) {
          bot.sendMessage(chatId, `No Vless account found for username: ${username}`);
          return;
        }

        const currentExpiration = new Date(expClients[username]);
        currentExpiration.setDate(currentExpiration.getDate() + days);
        expClients[username] = currentExpiration.toISOString().split("T")[0];

        writeExpClients(expClients);

        bot.sendMessage(chatId, `Vless account extended:\nUsername: ${username}\nNew expiration: ${expClients[username]}`);
      } catch (err) {
        bot.sendMessage(chatId, err.message);
      }
    });
  });
});

bot.onText(/\/delete_vless/, (msg) => {
  const chatId = msg.chat.id;
  bot.sendMessage(chatId, "Enter username to delete:");
  bot.once("message", (response) => {
    const username = response.text;
    try {
      const config = readConfig();
      const expClients = readExpClients();

      const index = config.inbounds[1].settings.clients.findIndex((c) => c.email === username);
      if (index === -1) {
        bot.sendMessage(chatId, `No Vless account found for username: ${username}`);
        return;
      }
      config.inbounds[1].settings.clients.splice(index, 1);
      delete expClients[username];
      writeConfig(config);
      writeExpClients(expClients);
      bot.sendMessage(chatId, `Vless account deleted:\nUsername: ${username}`);
    } catch (err) {
      bot.sendMessage(chatId, err.message);
    }
  });
});

bot.onText(/\/check_vless/, (msg) => {
  const chatId = msg.chat.id;
  try {
    const logPath = "/var/log/xray/access.log";
    const logs = fs.readFileSync(logPath, "utf8");
    const users = logs.match(/email":"(.*?)"/g).map((match) => match.split('"')[1]);
    const uniqueUsers = [...new Set(users)];
    bot.sendMessage(chatId, `Active Vless users:\n${uniqueUsers.join("\n")}`);
  } catch (err) {
    bot.sendMessage(chatId, `Error reading logs: ${err.message}`);
  }
});

// Trojan commands
bot.onText(/\/add_trojan/, (msg) => {
  const chatId = msg.chat.id;
  bot.sendMessage(chatId, "Enter username for the new Trojan account:");
  bot.once("message", (response) => {
    const username = response.text;
    bot.sendMessage(chatId, "Enter expiration days:");
    bot.once("message", (response) => {
      const days = parseInt(response.text, 10);
      try {
        const config = readConfig();
        const uuid = require("crypto").randomUUID();
        const expirationDate = new Date();
        expirationDate.setDate(expirationDate.getDate() + days);
        const newAccount = {
          id: uuid,
          email: username,
        };
        config.inbounds[2].settings.clients.push(newAccount);
        writeConfig(config);
        bot.sendMessage(chatId, `Trojan account added:\nUsername: ${username}\nUUID: ${uuid}\nExpires on: ${expirationDate.toISOString().split("T")[0]}`);
      } catch (err) {
        bot.sendMessage(chatId, err.message);
      }
    });
  });
});

bot.onText(/\/extend_trojan/, (msg) => {
  const chatId = msg.chat.id;
  bot.sendMessage(chatId, "Enter username to extend:");
  bot.once("message", (response) => {
    const username = response.text;
    bot.sendMessage(chatId, "Enter additional days:");
    bot.once("message", (response) => {
      const days = parseInt(response.text, 10);
      try {
        const expClients = readExpClients();
        if (!expClients[username]) {
          bot.sendMessage(chatId, `No Trojan account found for username: ${username}`);
          return;
        }

        const currentExpiration = new Date(expClients[username]);
        currentExpiration.setDate(currentExpiration.getDate() + days);
        expClients[username] = currentExpiration.toISOString().split("T")[0];

        writeExpClients(expClients);

        bot.sendMessage(chatId, `Trojan account extended:\nUsername: ${username}\nNew expiration: ${expClients[username]}`);
      } catch (err) {
        bot.sendMessage(chatId, err.message);
      }
    });
  });
});

bot.onText(/\/delete_trojan/, (msg) => {
  const chatId = msg.chat.id;
  bot.sendMessage(chatId, "Enter username to delete:");
  bot.once("message", (response) => {
    const username = response.text;
    try {
      const config = readConfig();
      const expClients = readExpClients();

      const index = config.inbounds[2].settings.clients.findIndex((c) => c.email === username);
      if (index === -1) {
        bot.sendMessage(chatId, `No Trojan account found for username: ${username}`);
        return;
      }
      config.inbounds[2].settings.clients.splice(index, 1);
      delete expClients[username];
      writeConfig(config);
      writeExpClients(expClients);
      bot.sendMessage(chatId, `Trojan account deleted:\nUsername: ${username}`);
    } catch (err) {
      bot.sendMessage(chatId, err.message);
    }
  });
});

bot.onText(/\/check_trojan/, (msg) => {
  const chatId = msg.chat.id;
  try {
    const logPath = "/var/log/xray/access.log";
    const logs = fs.readFileSync(logPath, "utf8");
    const users = logs.match(/email":"(.*?)"/g).map((match) => match.split('"')[1]);
    const uniqueUsers = [...new Set(users)];
    bot.sendMessage(chatId, `Active Trojan users:\n${uniqueUsers.join("\n")}`);
  } catch (err) {
    bot.sendMessage(chatId, `Error reading logs: ${err.message}`);
  }
});

// Set up the bot menu
bot.setMyCommands([
  { command: "/start", description: "Start the bot" },
  { command: "/help", description: "Show help message" },
  { command: "/view_config", description: "View the current Xray config.json" },
  { command: "/add_vmess", description: "Add a Vmess account" },
  { command: "/extend_vmess", description: "Extend a Vmess account" },
  { command: "/delete_vmess", description: "Delete a Vmess account" },
  { command: "/check_vmess", description: "Check Vmess user logins" },
  { command: "/add_vless", description: "Add a Vless account" },
  { command: "/extend_vless", description: "Extend a Vless account" },
  { command: "/delete_vless", description: "Delete a Vless account" },
  { command: "/check_vless", description: "Check Vless user logins" },
  { command: "/add_trojan", description: "Add a Trojan account" },
  { command: "/extend_trojan", description: "Extend a Trojan account" },
  { command: "/delete_trojan", description: "Delete a Trojan account" },
  { command: "/check_trojan", description: "Check Trojan user logins" },
]);

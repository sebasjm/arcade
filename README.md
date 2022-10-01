# Arcade Taler 

USB-Taler interface

## Requirements

**socat**: listen TCP connections, reply Websocket handshake, send reload command
**jq**: parse json
**qrencode**: optionally, generate and print qr codes for mobile integration

```
apt install socat jq qrencode -y
```

## Generate QR codes

qrencode -t asciii https://arcade.taler.ar/pay
qrencode -t asciii https://arcade.taler.ar/pickup


## Server Scripts

### Pickup

Create a reserve in the merchant. Use auth `TOKEN` and `RESERVE_ID`
Use the pickup server to listen to wallet request.

```
./pickup/serve.sh <input>
```

 * **TOKEN**: the auth token to access the merchant instance
 * **RESERVE_ID**: the reserve used for tipping the wallet
 * **input**: file that will parsed, one number by line

For every request, it will empty the content of `input` and authorize a tip and reply with the URL in the Location header.

### Pay

Create an order in the merchant. Use auth `TOKEN`
Use the pay server to listen to wallet request

```
./pay/serve.sh <directory>
```

 * **TOKEN**: the auth token to access the merchant instance
 * **RESERVE_ID**: the reserve used for tipping the wallet
 * **directory**: directory where the orders will be places

For every request, it will create an order to be paid and create a file in `directory`/`order_id`

Another process then can check the order status.

## Local Scripts

### Check

At the arcade machine. So it will run the game when it detects a payment.

```
./check/notify_insert_coin_when_paid.sh <order_ids...>
```

Will check of any order id and send an `insert coin` command if one is paid.

### Cash

At the door with the cash validator.

Connect the cash validator into the USB then.

```
./cash/listen_validator.sh <device>
```

 * **device**: the usb device where it will listen

It will send the signal to the pickup server


# am-fake_plates

A script to apply fake plates and custom fake plates to vehicles. Supports both ESX and Qbox out of the box, relying on `ox_lib`, `ox_inventory`, and `ox_target`.

## Features
- Apply fake plates to vehicles to hide the real plate.
- Apply custom plates with up to 8 characters.
- Check vehicle chassis using police jobs (configurable).
- Fully compatible with `ox_lib` (progress bars, dialogs, callbacks) and `ox_target`.
- Syncs state globally using State Bags across all clients.
- Auto-detects ESX and Qbox.

## Requirements
- `ox_lib`
- `ox_inventory`
- `ox_target`
- `es_extended` (for ESX servers) or `qbx_core` (for Qbox servers)

## Configuration
Edit `config.lua` to change the items needed, action durations, translation strings, and jobs permitted to check the real chassis of the vehicle.

## Installation
1. Ensure all requirements are started before this script.
2. Add the items `fake_plate` and `custom_fake_plate` to your `ox_inventory` items configuration.
3. Start `am-fakeplates` in your `server.cfg`.

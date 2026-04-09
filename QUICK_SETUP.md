# 🎯 QUICK REFERENCE: Что создавать в Studio

## 📦 СТРУКТУРА WORKSPACE

```
Workspace
├── Junkyard (Folder)
│   ├── TireSpawnPoint (Part) ×5
│   ├── [визуалы - куча мусора, контейнеры и т.д.]
│   └── ...
│
├── LaunchArea (Folder)
│   ├── LaunchPad (Part)
│   └── [визуалы - платформа для запуска]
│
├── Targets (Folder)
│   ├── Target (Part) ×3
│   ├── Target
│   └── Target
│
└── [Остальное: Terrain, Lighting, etc]
```

---

## 📱 СТРУКТУРА STARTERUI > MAINGUI

```
ReplicatedStorage
└── StarterGui
    └── MainUI (ScreenGui)
        ├── CoinsLabel (TextLabel)
        ├── TiresLabel (TextLabel)
        └── UpgradeFrame (Frame)
            ├── PowerLabel (TextLabel)
            ├── PowerUp (TextButton)
            ├── CarryLabel (TextLabel)
            └── CarryUp (TextButton)
```

---

## 📂 СТРУКТУРА СКРИПТОВ

```
ServerScriptService
├── Main.server.lua
└── Services (Folder)
    ├── BaseService.lua
    ├── DataService.lua
    ├── LaunchService.lua
    ├── UpgradeService.lua
    ├── PlayerService.lua
    ├── TargetService.lua
    ├── InteractionService.lua
    ├── TireService.lua
    ├── RebirthService.lua
    ├── TireSpawnerService.lua ← Sprint 1.2 NEW
    ├── LaunchPadService.lua ← Sprint 1.2 NEW
    └── DataSyncService.lua ← Sprint 1.2 NEW

StarterPlayer
├── StarterCharacterScripts
│   ├── CameraController.lua
│   └── FXController.lua
│
└── StarterPlayerScripts
    ├── LaunchController.client.lua
    └── UIController.client.lua

ReplicatedStorage
├── Shared (Folder) [скопировать из src/shared/]
│   ├── Config
│   │   ├── GameConfig.lua
│   │   ├── LaunchConfig.lua
│   │   ├── UpgradeConfig.lua
│   │   ├── EconomyConfig.lua ← UPDATE!
│   │   ├── TireConfig.lua ← NEW!
│   │   └── TireDefinitions.lua ← NEW!
│   │
│   ├── Types
│   │   └── PlayerDataSchema.lua ← UPDATE!
│   │
│   └── Modules
│       └── Loader.lua
│
├── Remotes (Folder) [создается автоматически]
│   ├── LaunchRequest (RemoteEvent)
│   ├── LaunchResult (RemoteEvent)
│   ├── UpgradeRequest (RemoteEvent)
│   ├── GetUpgradeInfo (RemoteFunction)
│   ├── DataChanged (RemoteEvent) ← AUTO
│   └── SelectTireToLaunch (RemoteEvent) ← AUTO
│
└── ServerPackages (Folder)
    └── ProfileService (Module)
```

---

## 🎨 ПРИМЕРЫ ЗНАЧЕНИЙ UI

### CoinsLabel & TiresLabel
```
Position: UDim2.new(0, [X], 0, [Y])
Size: UDim2.new(0, 200, 0, 50)
BackgroundColor3: Color3.fromRGB(50, 50, 50)
TextColor3: Color3.fromRGB(255, 255, 255)
TextSize: 18
BorderSizePixel: 0
```

### PowerLabel & CarryLabel
```
Size: UDim2.new(1, 0, 0, 70)
BackgroundColor3: Color3.fromRGB(100, 100, 100)
TextColor3: Color3.fromRGB(255, 255, 255)
TextWrapped: true
```

### PowerUp & CarryUp Buttons
```
Size: UDim2.new(1, 0, 0, 40)
BackgroundColor3: Color3.fromRGB(0, 170, 0) [зеленый]
TextColor3: Color3.fromRGB(255, 255, 255)
TextSize: 16
BorderSizePixel: 0
```

---

## 🔧 ЧАСТИ РЯДОМ С LAUNCHPAD

### Dummy (модель игрока для анимации)
Если у тебя есть R15 модель игрока:
- Скопировать R15 Character model
- Поставить рядом с LaunchPad (Y+5)
- Назвать "Dummy"
- **При запуске кода может быть присвоена автоматически**

---

## 🟢 ПРОВЕРКА ПЕРЕД ТЕСТОМ

### Консоль должна показать:
```
✅ ProfileService: Roblox API services available
✅ All services initialized
✅ Found X spawn points
🎯 Tire spawner started (max 15 tires)
```

### При подборе покрышки:
```
[Player] picked up: Car Gold (X/15)
```

### При запуске:
```
[Player] launched: Toy Gold | Reward: 15
```

---

## ⚙️ РАЗМЕРЫ И ПОЗИЦИИ (COPY-PASTE)

### TireSpawnPoint
- **Size:** (1, 1, 1)
- **CanCollide:** false
- **Transparency:** 0.5
- **Color:** RGB(255, 0, 0) красный

### LaunchPad
- **Size:** (3, 1, 3)
- **Color:** RGB(0, 255, 0) зеленый
- **Material:** Neon
- **CanCollide:** true

### Target
- **Size:** (2, 2, 2)
- **Color:** RGB(0, 100, 255) синий
- **CanCollide:** true

---

## 📋 МИНИМУМ ДЛЯ ТЕСТИРОВАНИЯ

Меньше всего нужно:
1. ✅ Junkyard + 1 TireSpawnPoint
2. ✅ LaunchArea + 1 LaunchPad
3. ✅ Targets + 1 Target  
4. ✅ MainUI + CoinsLabel + TiresLabel
5. ✅ UpgradeFrame + PowerLabel + PowerUp + CarryLabel + CarryUp
6. ✅ Все скрипты из src/server и src/client
7. ✅ Все конфиги из src/shared

**Это даст базовый тест. Добавь еще элементов для красоты!**

---

## 💡 СОВЕТЫ ПО ВИЗУАЛАМ

- **Junkyard:** используй модели контейнеров, ржавых машин, мусора из Toolbox
- **LaunchArea:** сделай платформу выше и добавь подсветку
- **Lighting:** 
  - Ambient: RGB(200, 200, 200) (яркое)
  - Brightness: 2
- **Sky:** используй стандартный Sky или загрузи с Toolbox
- **Humanoid (для Dummy):** Model > WaitForChild("Humanoid") перед использованием

---

Все! Этого хватит для полного тестирования Sprint 1.2! 🚀

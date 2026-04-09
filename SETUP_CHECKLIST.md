# CHECKLIST: Что сделать в Roblox Studio для тестирования Sprint 1.2

## 🎯 ОСНОВНЫЕ ЭЛЕМЕНТЫ (КРИТИЧНО)

### 1. **Junkyard** - Зона сбора покрышек
- [ ] Создать Folder в Workspace → назвать "Junkyard"
- [ ] Создать 5-10 **TireSpawnPoint** (простые Part, размер 1×1×1)
  - Разместить в разных местах Junkyard
  - Дать каждому имя "TireSpawnPoint"
  - Они будут спавнить покрышки рядом с собой
- [ ] Создать визуал Junkyard (куча мусора, контейнеры и т.д.)
  - Можно модели из Roblox Toolbox
  - Главное - чтобы игрок понимал, где искать покрышки

### 2. **LaunchArea** - Зона запуска
- [ ] Создать Folder в Workspace → назвать "LaunchArea"
- [ ] Создать 1-3 **LaunchPad** (Part, размер 3×1×3)
  - Дать каждому имя "LaunchPad"
  - Поставить на возвышении над Junkyard
  - ProximityPrompt должен создаться автоматически при запуске
- [ ] Рядом с LaunchPad поставить **Dummy** (модель игрока для анимации)
  - RemoteObjectValue в LaunchPad → "Dummy" (будет присваиваться на клиенте)
  - Здесь будет летать покрышка при запуске

### 3. **Targets** - Мишени для попаданий
- [ ] Создать Folder в Workspace → назвать "Targets"
- [ ] Создать 3-5 **Target** (Part, размер 2×2×2, яркий цвет)
  - На расстоянии ~50-100 от LaunchArea
  - Дать каждому имя "Target"
  - Когда покрышка летит в цель (distance < 5) → бонус ×2

---

## 🎮 UI ЭЛЕМЕНТЫ

### 4. **MainUI** (в PlayerGui)
Это должна быть ScreenGui. Внутри нужны:

```
ScreenGui (MainUI)
├── CoinsLabel (TextLabel)
│   ├── Text = "Coins: 0"
│   ├── Size = UDim2.new(0, 200, 0, 50)
│   ├── Position = UDim2.new(0.8, 0, 0, 10)
│   └── BackgroundColor = Color3.fromRGB(50, 50, 50)
│
├── TiresLabel (TextLabel)
│   ├── Text = "Tires: 0/5"
│   ├── Size = UDim2.new(0, 200, 0, 50)
│   ├── Position = UDim2.new(0.8, 0, 0, 70)
│   └── BackgroundColor = Color3.fromRGB(50, 50, 50)
│
└── UpgradeFrame (Frame)
    ├── Size = UDim2.new(0, 300, 0, 300)
    ├── Position = UDim2.new(0, 10, 0.8, 0)
    ├── Background = Color3.fromRGB(30, 30, 30)
    │
    ├── PowerLabel (TextLabel)
    │   ├── Text = "Power Lv.1 → 2\n+X | Cost: YY"
    │   └── Size = UDim2.new(1, 0, 0, 60)
    │
    ├── PowerUp (TextButton)
    │   ├── Text = "BUY"
    │   └── Size = UDim2.new(1, 0, 0, 40)
    │
    ├── CarryLabel (TextLabel)
    │   └── ...similar...
    │
    └── CarryUp (TextButton)
        └── ...similar...
```

**Как создать:**
1. Открыть StarterGui
2. Нажать "+" → ScreenGui → переименовать в "MainUI"
3. Внутри создать TextLabel "CoinsLabel" и "TiresLabel"
4. Создать Frame "UpgradeFrame"
5. Внутри UpgradeFrame создать 2 TextLabel + 2 TextButton для Power/Carry

---

## 📡 REMOTES (автоматически создаются при запуске, но можно проверить)

Должны быть в ReplicatedStorage.Remotes:
- [ ] LaunchRequest (RemoteEvent)
- [ ] LaunchResult (RemoteEvent)
- [ ] UpgradeRequest (RemoteEvent) 
- [ ] GetUpgradeInfo (RemoteFunction)
- [ ] DataChanged (RemoteEvent) ← **создается DataSyncService**
- [ ] SelectTireToLaunch (RemoteEvent) ← **создается LaunchPadService**

Если какой-то не создался → создать вручную как Instance.new("RemoteEvent"/"RemoteFunction")

---

## 🎨 ВАЖНЫЕ ВИЗУАЛЫ

### 5. **Lighting & Atmosphere**
- [ ] Настроить Lighting (освещение)
- [ ] Настроить Sky (небо)
- Так чтобы было видно разницу между Tires (разные цвета из TireConfig)

### 6. **Tire Spawns Preview**
При сборе покрышек должны видеться:
- Разные цвета (Normal=серый, Fire=красный, Ice=синий и т.д.)
- Разные формы (Cylinder Part размеры 1×1×3)

### 7. **Launch Trajectory Visualization** (опционально)
- [ ] Рядом с LaunchPad добавить стрелку/направление
- [ ] Чтобы игрок понимал, в какую сторону летит покрышка

---

## 🔧 СЕРВИС СТРУКТУРА (проверить в ServerScriptService)

- [ ] **Services** folder существует
- [ ] Внутри все .luau файлы:
  - BaseService.lua
  - DataService.lua
  - LaunchService.lua
  - UpgradeService.lua
  - PlayerService.lua
  - TargetService.lua
  - InteractionService.lua
  - TireService.lua
  - **RebirthService.lua** (новый)
  - **TireSpawnerService.lua** (новый)
  - **LaunchPadService.lua** (новый)
  - **DataSyncService.lua** (новый)

- [ ] **Main.server.lua** в ServerScriptService

---

## 📝 КОНТРОЛЕРЫ (проверить в StarterPlayer/StarterCharacterScripts / StarterPlayer/StarterPlayerScripts)

### Client Controllers:
- [ ] **LaunchController.client.lua** - (timing + trajectory)
- [ ] **UIController.client.lua** - (coins/tires labels + upgrades UI)
- [ ] **CameraController.lua** - (follow при запуске)
- [ ] **FXController.lua** - (частицы, звуки)

---

## 🧪 БЫСТРАЯ ПРОВЕРКА ПЕРЕД ТЕСТОМ

```lua
-- Запусти в Command Line (F9) чтобы проверить:
print(game:GetService("Workspace"):FindFirstChild("Junkyard")) -- должно быть folder
print(game:GetService("Workspace"):FindFirstChild("LaunchArea")) -- должно быть folder
print(game:GetService("Workspace"):FindFirstChild("Targets")) -- должно быть folder
print(game.StarterGui:FindFirstChild("MainUI")) -- должно быть ScreenGui
```

---

## ✅ ФИНАЛЬНЫЙ ЧЕКПОИНТ

Когда все готово, нужно увидеть:

**При запуске сервера:**
- Консоль: "✅ All services initialized"
- Консоль: "✅ Found X spawn points"
- Консоль: "🎯 Tire spawner started (max 15 tires)"

**При игре:**
1. В Junkyard появляются покрышки (разные цвета)
2. CoinsLabel & TiresLabel обновляют в реальном времени
3. Кнопки Power/Carry меняют цвет (зеленый = достаточно coins)
4. При подборе покрышки → пропадает из мира + обновляется UI
5. На LaunchPad → при клике показывается инвентарь
6. При запуске → покрышка летит (траектория зависит от типа)

---

## 📋 ПОРЯДОК СОЗДАНИЯ (рекомендуемый)

1. Создать папку структуру (Junkyard, LaunchArea, Targets)
2. Создать SpawnPoints в Junkyard
3. Создать LaunchPad в LaunchArea
4. Создать Targets в Targets
5. Создать MainUI структуру
6. Запустить сервер
7. Проверить консоль на ошибки
8. Войти в игру и тестировать

# ⚡ ГЛАВНОЕ: Что нужно создать в Studio для тестирования (5 минут)

## 📋 СПИСОК ДЕЛ (скопировать и галочка ✓)

### WORKSPACE Structure (2 минуты)
```
☐ Создать Workspace > Folder "Junkyard"
  ☐ Создать 3+ Part "TireSpawnPoint" внутри (Size: 1,1,1)
  
☐ Создать Workspace > Folder "LaunchArea"  
  ☐ Создать Part "LaunchPad" внутри (Size: 3,1,3)
  
☐ Создать Workspace > Folder "Targets"
  ☐ Создать 3+ Part "Target" внутри (Size: 2,2,2)
```

### UI (2 минуты)
```
☐ StarterGui > ScreenGui "MainUI"
  ☐ TextLabel "CoinsLabel" (Text: "Coins: 0")
  ☐ TextLabel "TiresLabel" (Text: "Tires: 0/5")
  ☐ Frame "UpgradeFrame"
    ☐ TextLabel "PowerLabel" 
    ☐ TextButton "PowerUp" (Text: "BUY")
    ☐ TextLabel "CarryLabel"
    ☐ TextButton "CarryUp" (Text: "BUY")
```

### Scripts & Config (1 минута)
```
☐ Скопировать все файлы из src/ в соответствующие места:
  ☐ ServerScriptService > Services/ (все .lua файлы)
  ☐ ServerScriptService > Main.server.lua
  ☐ StarterPlayer > StarterPlayerScripts > *.client.lua
  ☐ ReplicatedStorage > Shared/ (Config, Types, Modules)
```

---

## 🚀 БЫСТРЫЙ СТАРТ (копировать значения)

### Если лень расстраивать - минимальные значения:

```lua
-- TireSpawnPoint (5 штук)
Position: (0,2,0), (30,2,0), (-30,2,0), (0,2,30), (0,2,-30)
Size: 1, 1, 1
CanCollide: false

-- LaunchPad
Position: (0, 20, 0)
Size: 3, 1, 3
Color: Green (0, 255, 0)

-- Targets (3 штуки)
Position: (0,2,-50), (-20,2,-80), (20,2,-80)
Size: 2, 2, 2
Color: Blue (0, 100, 255)

-- CoinsLabel
Position: 900, 10
Size: 200, 50

-- TiresLabel
Position: 900, 70
Size: 200, 50

-- UpgradeFrame
Position: 10, 600
Size: 300, 300
```

---

## ✅ ПРОВЕРКА ДО ЗАПУСКА

```
1. Открыть Output (View > Output)
2. Click "Run"
3. Должно вывести:
   ✅ "All services initialized"
   ✅ "Found X spawn points"
   ✅ "Tire spawner started"
```

---

## 🎮 ТЕСТИРОВАНИЕ (что ты должен видеть)

1. **Сервер запустился** - консоль чистая, нет красных ошибок
2. **В Junkyard появляются разноцветные покрышки**
3. **Подходишь к покрышке** - показывается prompt (E)
4. **Нажимаешь E** - покрышка исчезает, обновляется "Tires: X/5"
5. **Идешь на LaunchPad** - зеленая платформа
6. **Нажимаешь E** - должно что-то произойти (зависит от UI)
7. **Видишь покрышку летящую** - траектория зависит от типа

---

## 📝 ВАЖНЫЕ ИМЕНА (must match exactly!)

Это case-sensitive, ошибка в имени = функционал не работает:
```
❌ "Tires" → ✅ "Tire" (Parts в мире)
❌ "SpawnPoints" → ✅ "TireSpawnPoint" (каждая точка отдельно)
❌ "LaunchPads" → ✅ "LaunchPad"
❌ "Targets" → ✅ "Target" (каждая мишень отдельно)
❌ Randomcase → ✅ ExactCase (именно как в коде)
```

---

## 📦 ФАЙЛЫ КОТОРЫЕ ОБНОВИЛИСЬ В SPRINT 1.2

Если скопируешь старые файлы - не будет работать! Нужны НОВЫЕ:

```
✅ NEW: src/shared/Config/TireConfig.lua
✅ NEW: src/shared/Config/TireDefinitions.lua  
✅ NEW: src/server/Services/TireSpawnerService.lua
✅ NEW: src/server/Services/LaunchPadService.lua
✅ NEW: src/server/Services/DataSyncService.lua
✅ UPDATE: src/shared/Config/EconomyConfig.lua
✅ UPDATE: src/shared/Types/PlayerDataSchema.lua
✅ UPDATE: src/server/Services/LaunchService.lua
✅ UPDATE: src/server/Services/DataService.lua
✅ UPDATE: src/server/Services/InteractionService.lua
✅ UPDATE: src/client/LaunchController.client.lua
```

---

## 🆘 ЕСЛИ ЧТО-ТО НЕ РАБОТАЕТ

Залезь в [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) - там 13 частых проблем с решениями!

Или выполни debug check:
```lua
-- F9 (Command Line) выполнить:
print(game.Workspace:FindFirstChild("Junkyard"))
print(game.Workspace:FindFirstChild("LaunchArea"))
print(game.StarterGui:FindFirstChild("MainUI"))
```

Если что-то выведет `nil` - его нужно создать!

---

## ⏱️ ОРИЕНТИРОВОЧНОЕ ВРЕМЯ

- Создать структуру: **5 минут**
- Создать UI: **5 минут**
- Скопировать скрипты: **2 минуты**
- Запустить и проверить: **3 минуты**

**Итого: ~15 минут на минимум, 30 минут если делать красиво**

---

**Готов? Начинай! После этого можно тестировать полноценный Tire System.** 🎉

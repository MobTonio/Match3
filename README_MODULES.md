# Match-3 Game - Модульная архитектура

## Обзор модулей

Игра Match-3 теперь имеет улучшенную модульную архитектуру со следующими компонентами:

### 1. GameFieldPositioning Module (`src/gamefieldPositioning.lua`)
**Назначение**: Чистый модуль для расчета позиций на игровом поле.

**Основные методы**:
- `GameFieldPositioning:new(field_size)` - создание экземпляра с размером поля
- `getBombArea(center_x, center_y)` - позиции для взрыва бомбы (3x3)
- `getRowPositions(y)` - все позиции в строке
- `getColumnPositions(x)` - все позиции в столбце
- `getColorPositions(field_grid, target_color)` - позиции определенного цвета
- `getCrossPositions(center_x, center_y)` - крестообразные позиции
- `getLShapePositions(center_x, center_y, direction)` - L-образные позиции
- `getDiagonalPositions(center_x, center_y, distance)` - диагональные позиции
- `getRadiusPositions(center_x, center_y, radius)` - позиции в радиусе
- `getRandomPositions(field_grid, count)` - случайные позиции

### 2. Field Module (`src/field.lua`)
**Назначение**: Управление игровым полем и выполнение операций уничтожения.

**Основные методы управления полем**:
- `Field:new()` - создание нового игрового поля
- `Field:init()` - инициализация поля со случайными кристаллами
- `Field:getGrid()` - получение текущего состояния поля
- `Field:swapCrystals(x1, y1, x2, y2)` - обмен кристаллов местами

**Методы уничтожения**:
- `destroyBombArea(center_x, center_y)` - уничтожить область бомбы
- `destroyRow(y)` - уничтожить строку
- `destroyColumn(x)` - уничтожить столбец
- `destroyColor(target_color)` - уничтожить все кристаллы цвета
- `destroyCross(center_x, center_y)` - уничтожить крест
- `destroyLShape(center_x, center_y, direction)` - уничтожить L-форму
- `destroyDiagonal(center_x, center_y, distance)` - уничтожить диагональ
- `destroyRadius(center_x, center_y, radius)` - уничтожить в радиусе

**Методы предварительного просмотра**:
- `getPreviewBombArea(center_x, center_y)` - предпросмотр области бомбы
- `getPreviewRow(y)` - предпросмотр строки
- `getPreviewColumn(x)` - предпросмотр столбца
- `getPreviewColor(target_color)` - предпросмотр цвета

### 3. SpecialStones Module (`src/special_stones.lua`)
**Назначение**: Определение типов специальных камней и их эффектов.

**Типы камней**:
- `BOMB` - взрывает область 3x3
- `LINE_H` - уничтожает горизонтальную линию
- `LINE_V` - уничтожает вертикальную линию
- `RAINBOW` - уничтожает все кристаллы определенного цвета
- `CROSS` - уничтожает крест (строка + столбец)
- `L_SHAPE` - уничтожает L-образную форму
- `DIAGONAL` - уничтожает диагональ

**Основные методы**:
- `createStone(x, y, stone_type, match_size)` - создание специального камня
- `activateStone(stone, field)` - активация камня (возвращает инструкции)
- `executeEffect(effect, field)` - выполнение эффекта через Field
- `previewEffect(effect, field)` - предварительный просмотр эффекта

### 4. Game Module (`src/game.lua`)
**Назначение**: Игровая логика и управление состоянием игры.

**Основные методы**:
- `Game:new()` - создание новой игры
- `Game:init()` - инициализация игры
- `Game:move(x, y, direction)` - выполнение хода игрока
- `Game:tick()` - обработка игрового цикла
- `Game:getScore()` - получение текущего счета

### 5. View Module (`src/view.lua`)
**Назначение**: Визуализация игры и пользовательский интерфейс.

**Основные методы**:
- `View:dump(field)` - отображение игрового поля
- `View:showInstructions()` - показ инструкций
- `View:showMessage(message)` - показ сообщений
- `View:showScore(score)` - отображение счета

## Преимущества новой архитектуры

1. **Четкое разделение ответственности**:
   - GameFieldPositioning - только расчет позиций
   - SpecialStones - только определение эффектов
   - Field - только выполнение операций на поле

2. **Переиспользование кода**: 
   - GameFieldPositioning можно использовать в других модулях
   - Легко добавлять новые типы эффектов

3. **Легкость тестирования**: 
   - Каждый модуль можно тестировать изолированно
   - Четкие интерфейсы между модулями

4. **Расширяемость**: 
   - Легко добавлять новые типы позиционирования
   - Простое добавление новых специальных эффектов

5. **Читаемость**: 
   - Понятная структура кода
   - Логичное разделение функций

## Взаимодействие модулей

```
main.lua
    ├── Game (src/game.lua)
    │   └── Field (src/field.lua)
    │       └── GameFieldPositioning (src/gamefieldPositioning.lua)
    ├── SpecialStones (src/special_stones.lua)
    │   ├── Field (для выполнения эффектов)
    │   └── GameFieldPositioning (через Field)
    └── View (src/view.lua)
```

## Поток выполнения специальных эффектов

1. **SpecialStones** определяет ЧТО нужно уничтожить (тип эффекта)
2. **Field** получает инструкции и узнает у **GameFieldPositioning** о конкретных позициях
3. **Field** выполняет уничтожение этих позиций
4. Результат возвращается обратно для обработки игрой

Этот подход обеспечивает максимальную гибкость и возможность легкого добавления новых типов эффектов и способов позиционирования.

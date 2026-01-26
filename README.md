# Drazzle

Flutter приложение для создания и сохранения рисунков в облаке с возможностью авторизации и синхронизации между устройствами.

# Скриншоты
<img width="300" height="600" alt="image" src="https://github.com/user-attachments/assets/b0f0fc66-d104-4ecb-9752-edbf0718c59e" />
<img width="300" height="600" alt="image" src="https://github.com/user-attachments/assets/f02c3677-6e28-4c94-a98d-235ea5bf535b" />
<img width="300" height="600" alt="image" src="https://github.com/user-attachments/assets/db1b35d4-940c-42cc-8ecd-f5a479b7eb0f" />

<img width="300" height="600" alt="image" src="https://github.com/user-attachments/assets/3723c0da-ea09-449a-b824-f760f3d9a072" />
<img width="300" height="600" alt="image" src="https://github.com/user-attachments/assets/ca97189c-5b02-468a-928a-70557aca76b1" />
<img width="300" height="600" alt="image" src="https://github.com/user-attachments/assets/d744f6e8-49c2-4376-880d-b6481217d3da" />
<img width="300" height="600" alt="image" src="https://github.com/user-attachments/assets/8ee8b312-d626-4928-8550-3cb27a4b577e" />
<img width="300" height="600" alt="image" src="https://github.com/user-attachments/assets/8ce476a8-c1d0-4f98-923d-383ffbff607b" />

<img width="300" height="600" alt="image" src="https://github.com/user-attachments/assets/4670f806-db7c-47d2-ab1a-33798bcdac27" />



## 🎨 Функционал

### 🔐 Авторизация
- Авторизация через почту и пароль с использованием Firebase Auth
- Безопасное хранение пользовательских данных

### 🖌️ Рисование
- Настройка размера кисти
- Выбор цвета кисти
- Импорт изображений из галереи в качестве холстов
- Редактирование ранее загруженных рисунков

### 💾 Сохранение и синхронизация
- Автоматическое сохранение рисунков в облаке (Cloud Firestore)
- Доступ к рисункам с любого устройства
- Экспорт рисунков в галерею устройства

### 📱 Уведомления
- Локальные уведомления о важных событиях
- Напоминания о сохраненных работах

### 🖥️ Просмотр
- Полноэкранный просмотр рисунков
- Удобная навигация между работами

## 🛠️ Технологический стек

### Управление состоянием
- **flutter_riverpod** - современное управление состоянием приложения

### Навигация
- **go_router** - декларативная навигация с поддержкой deep linking

### Firebase
- **firebase_auth** - аутентификация пользователей
- **cloud_firestore** - хранение файлов в облаке
- **firebase_core** - основа Firebase


### UI и UX
- **shimmer** - эффекты загрузки
- **flutter_svg** - работа с SVG графикой
- **cupertino_icons** - иконки в стиле iOS

### Работа с медиа
- **image_picker** - выбор изображений из галереи
- **permission_handler** - управление разрешениями
- **image** - обработка изображений
- **share_plus** - экспорт

### Утилиты
- **path_provider** - работа с файловой системой
- **email_validator** - валидация email адресов
- **flutter_local_notifications** - локальные уведомления


  

# SZM 阅读器

一个支持安卓与鸿蒙系统的文本阅读器解决方案示例，包含 Flutter 移动端与 Node.js 后台服务，支持上传文章与付费阅读。

## 项目结构

```
.
├── backend/   # Node.js + Express 后台 API
├── mobile/    # Flutter 移动端应用
└── docs/      # 文档与架构说明
```

## 后台服务

### 安装依赖

```bash
cd backend
npm install
```

### 开发模式启动

```bash
npm run dev
```

服务默认监听 `http://localhost:3000`，接口包括文章管理与购买模拟，可通过 Postman 或 curl 调试。

## 移动端应用

### 安装依赖

请在安装好 Flutter SDK 的环境下执行：

```bash
cd mobile
flutter pub get
```

### 运行到安卓设备/模拟器

```bash
flutter run -d android
```

### 构建鸿蒙应用

确保使用支持鸿蒙的 Flutter 通道（3.16+），执行：

```bash
flutter build hap --release
```

或参考鸿蒙 Flutter 文档使用 ArkUI Flutter 引擎构建。

### 配置后台地址

移动端默认使用 `http://localhost:3000`，发布到线上时可通过编译环境变量替换：

```bash
flutter run --dart-define=API_BASE_URL=https://api.example.com
```

## 更多信息

详见 [docs/architecture.md](docs/architecture.md)。

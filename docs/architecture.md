# SZM 阅读器系统架构

## 概述

系统由前端移动应用和后台管理 API 两部分组成：

- **移动端**：使用 Flutter 编写，一套代码同时支持安卓与鸿蒙平台。提供文章列表、阅读、购买解锁等功能。
- **后台 API**：使用 Node.js + Express 实现，提供文章上传、价格设置、购买记录等接口。默认使用 JSON 文件持久化，后续可替换为数据库。

## 移动端结构

```
mobile/
├── lib/
│   ├── main.dart                # 应用入口、主题与依赖注入
│   ├── models/                  # 数据模型（Article）
│   ├── services/                # 网络请求封装（ArticleService）
│   ├── state/                   # Provider 状态管理（ArticleProvider）
│   ├── screens/                 # 页面（文章列表、阅读页）
│   └── widgets/                 # 组件（文章卡片等）
└── pubspec.yaml                 # 依赖声明
```

### 关键交互流程

1. `ArticleProvider.loadArticles()` 调用 `ArticleService.fetchArticles()` 获取文章列表。
2. 用户点击文章进入阅读页，`ArticleReaderPage` 会刷新文章详情。
3. 对于付费文章，阅读页会提示支付按钮，调用 `ArticleProvider.purchaseArticle()` 完成购买后重新拉取文章内容。

### 适配安卓与鸿蒙

Flutter 框架天然支持多平台构建。通过在鸿蒙系统使用 ArkUI Flutter 引擎或通过鸿蒙的 Flutter 兼容层，可以直接复用此项目代码。具体打包流程参考 `README.md` 中的说明。

## 后台 API 结构

```
backend/
├── src/
│   ├── server.ts    # Express 服务入口及路由
│   ├── storage.ts   # JSON 文件持久化实现
│   └── types.ts     # TypeScript 类型定义
├── package.json
└── tsconfig.json
```

### 核心接口

- `POST /articles`：上传文章（标题、内容、价格等）。
- `PATCH /articles/:id`：更新文章内容或价格。
- `GET /articles`：列表接口，返回带权限信息的文章摘要。
- `GET /articles/:id`：单篇文章详情，自动根据用户购买情况返回全文或预览。
- `POST /articles/:id/purchase`：记录用户购买行为，当前示例使用 demo 用户 ID，可接入真实支付系统。

### 数据存储

`JsonStorage` 将数据保存在 `data.json` 文件。正式环境可替换为 MySQL、MongoDB 或云数据库，只需实现同样的方法即可。

## 部署建议

1. **后台**：部署至云服务器或容器平台，配置 `DATABASE_PATH` 指向持久化存储路径。生产环境建议放在 HTTPS 域名下并接入支付网关。
2. **移动端**：通过 Flutter 命令分别构建 `apk`/`aab` 与鸿蒙 `hap` 包，必要时在代码中替换 `ArticleService.baseUrl` 指向线上环境。
3. **鉴权与支付**：示例中仅模拟用户 ID，实际应用需接入账号体系与支付 SDK，并在购买接口中校验支付凭证。

## 后续扩展

- 增加后台管理界面，实现文章上传与价格配置的可视化操作。
- 引入用户登录、阅读历史、书签、夜间模式等体验优化。
- 将存储替换为数据库，并引入缓存提升列表加载速度。
- 接入第三方支付（如微信、支付宝）并在后端验证支付通知。

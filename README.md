# Wardrobe 👕

一个基于 Flutter 开发的数字衣柜管理 App。

Wardrobe 用于管理个人/亲友衣物，并为后续的穿搭推荐等功能提供基础。

## Features

当前已实现：

* 衣柜主页

  * 衣物分类展示
  * 卡片式衣物 UI
  * 衣物图片展示

* 衣物管理

  * 拍照添加衣物
  * 衣物名称、品牌、颜色、分类、季节、价格
  * Private / Public 可见性设置
  * 衣物本地图片保存

* 好友系统

  * 查找用户
  * 发送/处理好友申请
  * 好友备注
  * 删除好友
  * 查看好友资料/衣柜

* 个人中心

  * 用户信息
  * 设置页面
  * 主题切换

* 主题

  * Light / Dark 模式

## Project Structure

```text
lib/
├── models/          # 数据模型
├── pages/           # 页面
├── services/        # 业务逻辑与数据仓库
├── widgets/         # 通用 UI 组件
└── ...
```

## Getting Started

### Requirements

* Flutter SDK
* Android Studio / VS Code
* Android Emulator 或 Android 实体设备

检查 Flutter 环境：

```bash
flutter doctor
```

运行项目：

```bash
flutter pub get
flutter run
```

## TODO

* [ ] 好友穿搭推荐
* [ ] AI 衣物识别
* [ ] 天气联动
* [ ] 云端数据同步

## License

MIT License

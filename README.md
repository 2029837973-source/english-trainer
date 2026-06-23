# 英语听说训练器

把任意视频/音频里的真人原声扒下来，**边盲听边在电脑上打字对答案**，再用影子跟读和音素级发音评测把发音练对。省掉"手动点暂停/倒带 + 纸上手写"的笨功夫，本地运行、免费。

> 网页前端 + 本地 Python 后端。可以自己本地跑，也能发给装了 Python 的朋友用。

<!-- 建议在这里放一两张界面截图，比如 docs/screenshot.png -->

---

## 它能做什么

- **素材提取**：粘贴视频链接（YouTube / Bilibili / X 等 yt-dlp 支持的站点），自动取**字幕**；没字幕则本地 **Whisper** 转写。也支持只提取某个**时间段**，以及上传 **PDF / Word** 提取文字。
- **四种练习模式**
  - **盲听**：只听不看，把听到的打出来，自动对答案（绿=对 / 红=听错 / 删除线=漏听）。`Enter` 对比、再 `Enter` 进下一句。
  - **听力**：点单词看音标、听标准发音。
  - **跟读**：录音后用 **Azure 发音评测**给出总分 + 逐词 + 逐音素打分（没配 key 时自动退回浏览器识别，免费无限）。
  - **连读**：整篇逐词高亮，做影子跟读。
- **标准音 vs 真人原声**：视频句子放**真人原声**（连读、弱读、真实口音都在）；点单词给 **Edge TTS 标准音**（可切美音/英音）。
- **历史记录**：自动保存进度，可继续上次练。
- **可选**：去除背景音乐 / 人声分离（Demucs）。

---

## 快速开始

### 1. 前置条件
- **Python 3.10 或 3.11**
- **ffmpeg** 装好并在 PATH 里（转码、Whisper、发音评测都用它）
  - Windows：`winget install Gyan.FFmpeg` 或到 ffmpeg.org 下载后把 bin 加进 PATH
  - macOS：`brew install ffmpeg`

### 2. 安装
```bash
python -m venv .venv
# Windows:
.venv\Scripts\activate
# macOS/Linux:
source .venv/bin/activate

pip install -r requirements.txt
```

### 3. 运行
```bash
python -m uvicorn app:app --port 8000
```
浏览器打开 **http://localhost:8000** 即可。

> 务必用 `localhost`/`127.0.0.1` 访问，否则浏览器不给麦克风权限（跟读录音用得到）。

---

## 配置（都是可选的，按需自己填）

本仓库**不包含**任何账号凭证或密钥——你需要用哪个功能，就填自己的。

### Bilibili 视频：自己的登录 cookie
B站对未登录请求会返回 412。其它站点（YouTube 等）通常不需要。需要练 B站 时：
1. 浏览器装扩展 **"Get cookies.txt LOCALLY"**，登录 B站；
2. 导出 `cookies.txt`，放到**项目根目录**（和 `app.py` 同级）；
3. 程序每次请求会自动读取，**不用重启**。

> `cookies.txt` 是你的登录态，**切勿外发、切勿提交到 git**（已在 `.gitignore` 里挡掉）。

### 发音评测：自己的 Azure key
跟读模式的精准评分用 Azure 语音服务（有免费额度 F0：每月 5 小时）。**不配也能用**——会自动退回浏览器识别（免费无限，只是不如 Azure 精准）。要用精准评分：
1. 注册 Azure，创建一个 **Speech** 资源（选 **Free F0** 不会扣费）；
2. 在项目根建 `azure_key.txt`：第 1 行写 key，第 2 行写区域（如 `southeastasia`）；
3. 或用环境变量 `AZURE_SPEECH_KEY` / `AZURE_SPEECH_REGION`。重启生效。

> `azure_key.txt` 同样**别外发、别提交 git**。

### 可选功能：去背景音（Demucs）
需要额外装 torch（**先**装 CPU 版再装 demucs）：
```bash
pip install torch==2.2.2 torchaudio==2.2.2 --index-url https://download.pytorch.org/whl/cpu
pip install demucs==4.0.1
```

---

## 兼容性踩坑（重要）

`requirements.txt` 里几个版本是**特意锁死**的，因为在作者的机器（AMD Ryzen 6000 系 CPU）上最新版会崩：
- **`ctranslate2==4.4.0`**：更高版本加载 faster-whisper 模型会**直接段错误**（exit 139，无 traceback），整个服务挂掉。
- **`numpy==1.26.4`（<2）**：否则报 "Failed to initialize NumPy"。
- **可选的 torch 用 `2.2.2` CPU 版**：最新 torch 在该机器上导入即崩（c10.dll 初始化失败）。

如果你的硬件较新、想试更高版本，可以自行放开这些锁；遇到上述崩溃就退回这些版本。

---

## 免责声明

本项目是**个人英语学习工具**，仅供学习研究使用。使用者需自行遵守相关视频平台的服务条款与版权规定，对所提取内容的使用负责。请勿用于侵犯版权或商业用途。作者不对使用本工具产生的任何后果负责。

底层视频提取依赖开源项目 [yt-dlp](https://github.com/yt-dlp/yt-dlp)。

---

## License

[MIT](./LICENSE) — 记得把 LICENSE 里的 `<YOUR NAME OR GITHUB HANDLE>` 换成你自己的名字/用户名。

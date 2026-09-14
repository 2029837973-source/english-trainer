# 配置指南：B站 Cookie 与 Azure 发音评测

> 三个模式（盲听 / 听力 / 连读）零配置就能用，粘段英文或贴个 YouTube 链接即可开练。
> 下面两项都是**可选**的，按需配置：想练 **B站视频**配第一项，想要**真实发音打分**配第二项。
> 配完不用改代码、不用重启服务（cookie 每次请求现读，key 改完重启一次即可）。

---

## 一、B站视频：导出登录 Cookie

**为什么需要**：B站对未登录请求返回 `HTTP 412 Precondition Failed`，yt-dlp 取不到视频。带上你自己的登录 cookie 就能正常提取。YouTube / X 等站点一般**不需要**这一步。

### 步骤

1. **装浏览器扩展 "Get cookies.txt LOCALLY"**
   - Chrome / Edge：**到官方扩展商店**（Chrome 应用商店 / Edge 加载项）搜索 `Get cookies.txt LOCALLY`（认准 LOCALLY，本地导出、不上传），点安装。
   - ⚠️ 这个扩展能读你浏览器**所有 cookie（含各网站登录态）**，所以**只从官方商店装**——别从随便的链接下个 `.crx`/`.zip` 文件侧载，万一是被改过的版本会泄露你的登录态。
   - 这是目前最稳的方式。直接让 yt-dlp 从浏览器读 cookie 在很多 Windows 机器上会因 Edge/Chrome 的应用级加密失败，所以用扩展手动导出更可靠。

2. **登录 B站**
   - 浏览器打开 [bilibili.com](https://www.bilibili.com) 并**确保已登录**（右上角能看到你的头像）。
   - 访客 cookie（只有 buvid3 那种）不够，必须是**登录态**的 cookie（导出文件里会包含登录会话字段）。

3. **导出 cookies.txt**
   - 在 B站 页面上点扩展图标 → **Export**（或 "Export as cookies.txt"）。
   - 会下载一个 `cookies.txt` 文件。

4. **放到项目根目录**
   - 把 `cookies.txt` 移动到 `english-trainer/`（与 `app.py` 同级）。
   - 程序会**自动识别**，无需重启、无需改配置。
   - 也支持别的文件名/路径：设环境变量 `YT_COOKIES_FILE=D:\path\to\cookies.txt`（优先级更高）。
   - **部署在 Render 时**：不要把 Cookie 提交到 Git。请在服务的 **Environment → Secret Files** 中添加文件名 `cookies.txt`，粘贴文件内容；Docker 内会以 `/etc/secrets/cookies.txt` 提供，程序会自动识别。保存后重新部署，再访问 `/api/health` 确认 `bilibili_cookie` 为 `true`。

5. **验证**
   - 回到网页，贴一个 B站 视频链接，点"提取并开始练"。出句子就成功了。

### 注意

- `cookies.txt` 含你的**完整登录态**，泄露可能被盗号。**切勿外发、切勿提交 git**（本仓库 `.gitignore` 已默认忽略它）。
- Cookie 会过期。再次 412 时，按上面重新导出、覆盖旧文件即可。
- 有些 B站 视频是**硬字幕**（字幕烧进画面），yt-dlp 取不到字幕轨，会自动走本地 Whisper 转写，稍慢但质量不错。

---

## 二、Azure 发音评测：拿 Speech 资源 Key

**为什么需要**：跟读模式要做**音素级**真实发音打分（准确度 / 流利度 / 完整度 / 韵律，细到每个音素），靠的是 Azure 发音评测。
不配也能用——会退回浏览器语音识别做"说没说对词"的文字匹配，但那**不是真实发音评分**，而且依赖 Google、**国内常常连不上**。所以想认真练发音，建议配。

免费档 **F0 每月 5 小时**，用满只报错、**不扣费**（选 F0，别选 S0）。

### 步骤

1. **注册 Azure 账号**
   - 普通注册需要绑信用卡（有 12 个月免费额度）。
   - **学生推荐 [Azure for Students](https://azure.microsoft.com/free/students/)**：用学校邮箱注册，**无需信用卡**，送 $100 额度 / 365 天。

2. **创建 Speech 资源**
   - 进 [Azure Portal](https://portal.azure.com) → 搜索 **Speech services**（语音服务）→ Create。
   - 填：订阅、资源组（新建一个如 `englishtrainer`）、区域、名称、定价层选 **Free F0**。
   - **区域选 `Southeast Asia`（东南亚）**。⚠️ 实测 Azure for Students 订阅在 `East Asia` 会被区域策略 `RequestDisallowedByAzure` 拦掉，用 `Southeast Asia` 可以。普通订阅可按就近选。

3. **拿 Key 和 Region**
   - 资源建好后进去 → 左侧 **Keys and Endpoint**（密钥和终结点）。
   - 复制 **KEY 1**（或 KEY 2，二选一）和 **Location/Region**（如 `southeastasia`）。

4. **填进项目（任选一种）**
   - **最省事：让你的 AI agent 帮你弄**——把 key 发给它，它会写进项目根的 `azure_key.txt` 并让其生效（agent 可 POST `/api/config/azure` 即时生效、不用重启）。整个过程在你和 AI 的对话里完成，App 里没有设置入口。
   - 或自己在项目根建 `azure_key.txt`（第1行 key，第2行 region），或设环境变量 `AZURE_SPEECH_KEY` / `AZURE_SPEECH_REGION`（环境变量优先）。自己改文件后重启一次服务。

5. **验证**
   - 浏览器访问 `http://localhost:8000/api/health`，返回 `"azure": true` 即配置成功。
   - 进跟读模式，引擎选 "Azure 精准"，录一句话即可看到打分。

### 注意

- `azure_key.txt` 是你的密钥，**切勿贴聊天、切勿提交 git**（`.gitignore` 已默认忽略）。一旦泄露，去 Portal 点 **Regenerate Key** 作废重生成。
- 额度用完（F0 每月 5 小时）后，跟读框可切到"基础(免费无限)"引擎继续练，下月 1 号额度重置再切回。

---

## 出问题时

| 现象 | 可能原因 / 处理 |
|---|---|
| B站 一直 412 | cookie 没放对位置 / 过期 / 不是登录态。重新导出覆盖。 |
| `/api/health` 里 `azure:false` | `azure_key.txt` 没放对、格式不对，或没重启服务。 |
| 建 Azure 资源报 `RequestDisallowedByAzure` | 学生订阅换 `Southeast Asia` 区域。 |
| 跟读点录音没反应 | 用 `http://localhost:8000` 访问（不要用局域网 IP），否则浏览器不给麦克风权限。 |
| 视频转写很慢 | 优先选**有字幕**的视频（秒出），或用"只练某一段"只处理你要练的区间。 |

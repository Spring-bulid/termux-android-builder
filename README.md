# Termux 全能 Android 编译包

一个在 Termux 上运行的全能 Android 编译环境，整合了 Android SDK、Ubuntu chroot、ARM 交叉编译工具链和 AnyKernel3 模板。

## 功能特性

- **Android SDK**: 完整的 Android 开发工具包
- **Ubuntu chroot**: 通过 proot 运行的 Ubuntu 22.04 环境
- **ARM 工具链**: AOSP Clang + GCC 交叉编译工具链
- **AnyKernel3**: 内核打包和刷入模板

## 系统要求

- **设备**: 任何 Android 设备 (aarch64)
- **Android 版本**: Android 12-15
- **内存**: 建议至少 6GB RAM
- **存储**: 建议至少 10GB 可用空间
- **Termux**: 需要安装 Termux 应用

## 快速开始

### 1. 安装 Termux

从 F-Droid 或 GitHub 下载安装 Termux 应用：
- F-Droid: https://f-droid.org/packages/com.termux/
- GitHub: https://github.com/termux/termux-app/releases

### 2. 克隆此仓库

```bash
git clone https://github.com/Spring-bulid/termux-android-builder.git
cd termux-android-builder
```

### 3. 运行安装脚本

```bash
bash install.sh
```

安装脚本会自动：
- 更新 Termux 包管理器
- 安装基础依赖
- 安装 Android SDK
- 安装 ARM 交叉编译工具链
- 安装 Ubuntu chroot 环境
- 配置 AnyKernel3 模板

### 4. 检查环境

```bash
bash env-check.sh
```

### 5. 编译内核

```bash
bash build-kernel.sh -k ~/kernel -c vendor/defconfig
```

## 目录结构

```
termux-android-builder/
├── install.sh              # 主安装脚本
├── setup-sdk.sh            # Android SDK 安装
├── setup-ubuntu.sh         # Ubuntu chroot 安装
├── setup-toolchain.sh      # ARM 交叉编译工具链
├── setup-anykernel3.sh     # AnyKernel3 模板配置
├── build-kernel.sh         # 内核编译入口脚本
├── enter-chroot.sh         # 进入 Ubuntu chroot
├── env-check.sh            # 环境检查脚本
├── config/
│   ├── kernel_defconfig    # 默认内核配置
│   └── toolchain.env       # 工具链环境变量
├── LICENSE                 # GPL-3.0 许可证
└── README.md               # 使用说明
```

## 使用说明

### 进入 Ubuntu 环境

```bash
# 快速进入 Ubuntu
ubuntu

# 或使用脚本进入
bash enter-chroot.sh
```

### 安装内核编译依赖

```bash
bash enter-chroot.sh -i
```

### 编译内核

```bash
# 基本用法
bash build-kernel.sh -k ~/kernel

# 指定 defconfig
bash build-kernel.sh -k ~/kernel -c vendor/oneplus9_defconfig

# 清除之前的编译
bash build-kernel.sh -k ~/kernel -C

# 指定编译线程数
bash build-kernel.sh -k ~/kernel -j 8
```

### AnyKernel3 打包

```bash
# 进入 AnyKernel3 目录
cd ~/AnyKernel3

# 复制内核镜像
cp ~/kernel/arch/arm64/boot/Image.gz .

# 编辑配置
nano anykernel.sh

# 打包
zip -r9 kernel.zip * -x .git/*
```

## 设备支持

### 高通设备

大多数高通 Snapdragon 设备都支持，包括：
- OnePlus 系列
- 小米/Redmi 系列
- 三星 Galaxy 系列
- Google Pixel 系列
- Sony Xperia 系列

### 联发科设备

联发科设备也支持，包括：
- Redmi Note 系列
- Realme 系列
- Oppo 系列
- Vivo 系列
- Nothing Phone 系列

## 常见问题

### Q: 编译时内存不足怎么办？

A: 建议手机至少 6GB RAM。如果内存不足，可以：
1. 减少编译线程数：`-j 2`
2. 使用交换空间
3. 在 Ubuntu 环境中编译

### Q: 如何查看设备的 defconfig？

A: 通常在内核源码的以下位置：
- `arch/arm64/configs/`
- `vendor/`
- `device/`

### Q: 编译出的内核如何刷入？

A: 可以使用以下方式：
1. **Magisk**: 将内核 Image 放到 `/sdcard/Download/`，使用 Magisk Manager 刷入
2. **TWRP**: 将 kernel.zip 通过 TWRP Recovery 刷入
3. **KernelSU**: 支持 KernelSU 的设备可以直接使用

### Q: 如何更新工具链？

A: 重新运行安装脚本：
```bash
bash setup-toolchain.sh
```

## 高级用法

### 自定义工具链版本

编辑 `setup-toolchain.sh` 中的版本号：
```bash
CLANG_VERSION="r416183b"  # 修改为你需要的版本
```

### 添加设备配置

在 `setup-anykernel3.sh` 中的 `create_device_configs` 函数添加新配置。

### 使用交换空间

```bash
# 创建 4GB 交换空间
fallocate -l 4G /sdcard/swapfile
chmod 600 /sdcard/swapfile
mkswap /sdcard/swapfile
swapon /sdcard/swapfile
```

## 许可证

本项目采用 **GNU General Public License v3.0** 许可证。

详见 [LICENSE](LICENSE) 文件。

## 贡献

欢迎提交 Issue 和 Pull Request！

## 致谢

### 项目创建者

- **Spring-bulid** - 项目创建者和维护者

### Termux 官方团队

感谢 Termux 官方团队的不懈努力：
- [Termux](https://github.com/termux) - 官方 GitHub 组织
- [termux-app](https://github.com/termux/termux-app) - 主应用程序
- [termux-packages](https://github.com/termux/termux-packages) - 软件包构建系统
- [termux-api](https://github.com/termux/termux-api) - API 扩展

### Termux 赞助者

感谢以下赞助者对 Termux 项目的支持：

**当前赞助者:**
- [@txoof](https://github.com/txoof)
- [@luisoala](https://github.com/luisoala)
- [@akovalenko](https://github.com/akovalenko)
- [@dedsec1121fk](https://github.com/dedsec1121fk)
- [@thomas-ovens](https://github.com/thomas-ovens)
- [@maxamillion](https://github.com/maxamillion)
- [@yamsergey](https://github.com/yamsergey)
- [@sdiggly](https://github.com/sdiggly)
- [@hagaddour](https://github.com/hagaddour)
- [@JunkFood02](https://github.com/JunkFood02)
- [@snydergd](https://github.com/snydergd)
- [@john-peterson](https://github.com/john-peterson)
- [@zark0s](https://github.com/zark0s)
- [@rosetintedcheeks](https://github.com/rosetintedcheeks)
- [@s-alad](https://github.com/s-alad)
- [@rodrigojfagundes](https://github.com/rodrigojfagundes)
- [@h0tk3y](https://github.com/h0tk3y)
- [@mkt](https://github.com/mkt)
- [@eave](https://github.com/eave)
- [@sng2c](https://github.com/sng2c)
- [@digitalby](https://github.com/digitalby)
- [@chapmanjacobd](https://github.com/chapmanjacobd)
- [@CorvetteCole](https://github.com/CorvetteCole)
- [@pschmitt](https://github.com/pschmitt)
- [@upsuper](https://github.com/upsuper)
- [@darkgeek](https://github.com/darkgeek)
- [@JM0804](https://github.com/JM0804)
- [@kennethso168](https://github.com/kennethso168)

**历史赞助者:**
- [@nanotee](https://github.com/nanotee)
- [@fcelega](https://github.com/fcelega)
- [@lybekk](https://github.com/lybekk)
- [@stutstev](https://github.com/stutstev)
- [@EdwardD808](https://github.com/EdwardD808)
- [@itsseanl](https://github.com/itsseanl)
- [@twlswan](https://github.com/twlswan)
- [@remram44](https://github.com/remram44)
- [@ADS-Fund](https://github.com/ADS-Fund)
- [@jjtseng93](https://github.com/jjtseng93)
- [@nouraellm](https://github.com/nouraellm)
- [@aspyct](https://github.com/aspyct)
- [@bona-ws](https://github.com/bona-ws)

### Termux App 贡献者

感谢以下为 termux-app 做出贡献的开发者：

- [@agnostic-apollo](https://github.com/agnostic-apollo)
- [@fornwall](https://github.com/fornwall)
- [@Grimler91](https://github.com/Grimler91)
- [@maoabc](https://github.com/maoabc)
- [@robertvandeneynde](https://github.com/robertvandeneynde)
- [@trygveaa](https://github.com/trygveaa)
- [@tareksander](https://github.com/tareksander)
- [@xqdoo00o](https://github.com/xqdoo00o)
- [@landfillbaby](https://github.com/landfillbaby)
- [@hannesa2](https://github.com/hannesa2)
- [@Quasic](https://github.com/Quasic)
- [@whydoubt](https://github.com/whydoubt)
- [@mklein994](https://github.com/mklein994)
- [@rakslice](https://github.com/rakslice)
- [@michalbednarski](https://github.com/michalbednarski)
- [@thunder-coding](https://github.com/thunder-coding)
- [@x0b](https://github.com/x0b)
- [@VinDeville](https://github.com/VinDeville)
- [@pvagner](https://github.com/pvagner)
- [@friederbluemle](https://github.com/friederbluemle)
- [@dkramer95](https://github.com/dkramer95)
- [@utzcoz](https://github.com/utzcoz)
- [@nikam14](https://github.com/nikam14)
- [@easyaspi314](https://github.com/easyaspi314)
- [@kzlin129](https://github.com/kzlin129)
- [@tomty89](https://github.com/tomty89)
- [@SDRausty](https://github.com/SDRausty)
- [@Archenoth](https://github.com/Archenoth)
- [@Auxilus](https://github.com/Auxilus)
- [@quite](https://github.com/quite)
- [@robertkirkman](https://github.com/robertkirkman)
- [@kdrag0n](https://github.com/kdrag0n)
- [@rozPierog](https://github.com/rozPierog)
- [@moneytoo](https://github.com/moneytoo)
- [@MatanZ](https://github.com/MatanZ)
- [@Nickoriginal](https://github.com/Nickoriginal)
- [@nishithkhanna](https://github.com/nishithkhanna)
- [@RangerMauve](https://github.com/RangerMauve)
- [@sachac](https://github.com/sachac)
- [@Sandelinos](https://github.com/Sandelinos)
- [@bumper314](https://github.com/bumper314)
- [@Sushrut1101](https://github.com/Sushrut1101)
- [@TpmKranz](https://github.com/TpmKranz)
- [@TotalCaesar659](https://github.com/TotalCaesar659)
- [@aviraxp](https://github.com/aviraxp)
- [@Young-Lord](https://github.com/Young-Lord)
- [@0xXA](https://github.com/0xXA)
- [@PolpOnline](https://github.com/PolpOnline)
- [@the-blank-x](https://github.com/the-blank-x)
- [@cn00](https://github.com/cn00)
- [@daywalk3r666](https://github.com/daywalk3r666)
- [@doubleblinddoubleblinddoubleblind](https://github.com/doubleblinddoubleblinddoubleblind)
- [@iamahuman](https://github.com/iamahuman)
- [@l-jonas](https://github.com/l-jonas)
- [@neverwin](https://github.com/neverwin)
- [@scarf005](https://github.com/scarf005)
- [@hisirdox](https://github.com/hisirdox)
- [@aribmuhtasim](https://github.com/aribmuhtasim)
- [@AChep](https://github.com/AChep)
- [@danog](https://github.com/danog)
- [@Dvd-Znf](https://github.com/Dvd-Znf)
- [@Edontin](https://github.com/Edontin)
- [@EduardDurech](https://github.com/EduardDurech)
- [@EdwardBetts](https://github.com/EdwardBetts)
- [@ezhd](https://github.com/ezhd)
- [@evelikov](https://github.com/evelikov)
- [@evg-zhabotinsky](https://github.com/evg-zhabotinsky)
- [@fmeum](https://github.com/fmeum)
- [@obfusk](https://github.com/obfusk)
- [@zevv](https://github.com/zevv)
- [@jasonjyu](https://github.com/jasonjyu)
- [@jeansch](https://github.com/jeansch)
- [@krobelus](https://github.com/krobelus)
- [@xJonathanLEI](https://github.com/xJonathanLEI)
- [@debugrr](https://github.com/debugrr)
- [@joshtriplett](https://github.com/joshtriplett)
- [@kevin-canadian](https://github.com/kevin-canadian)
- [@2096779623](https://github.com/2096779623)
- [@Kruna1Pate1](https://github.com/Kruna1Pate1)
- [@lotheac](https://github.com/lotheac)

### Termux Packages 贡献者

感谢以下为 termux-packages 做出贡献的开发者：

- [@xtkoba](https://github.com/xtkoba)
- [@Biswa96](https://github.com/Biswa96)
- [@twaik](https://github.com/twaik)
- [@licy183](https://github.com/licy183)
- [@TomJo2000](https://github.com/TomJo2000)
- [@truboxl](https://github.com/truboxl)
- [@MrAdityaAlok](https://github.com/MrAdityaAlok)
- [@finagolfin](https://github.com/finagolfin)
- [@Maxython](https://github.com/Maxython)
- [@BullyMaguire-lol](https://github.com/BullyMaguire-lol)
- [@sylirre](https://github.com/sylirre)
- [@its-pointless](https://github.com/its-pointless)
- [@tqfx](https://github.com/tqfx)
- [@stephengroat](https://github.com/stephengroat)
- [@kcubeterm](https://github.com/kcubeterm)
- [@pvonmoradi](https://github.com/pvonmoradi)
- [@Neo-Oli](https://github.com/Neo-Oli)
- [@librehat](https://github.com/librehat)
- [@Wetitpig](https://github.com/Wetitpig)
- [@vishalbiswas](https://github.com/vishalbiswas)
- [@creepy-pasta101](https://github.com/creepy-pasta101)
- [@knyipab](https://github.com/knyipab)
- [@zorro](https://github.com/zorro)
- [@sabamdarif](https://github.com/sabamdarif)
- [@s00se](https://github.com/s00se)
- [@ifurther](https://github.com/ifurther)
- [@tjhexf](https://github.com/tjhexf)
- [@Yonle](https://github.com/Yonle)
- [@vaites](https://github.com/vaites)
- [@valpogus](https://github.com/valpogus)
- [@FreddieOliveira](https://github.com/FreddieOliveira)
- [@asumbek](https://github.com/asumbek)
- [@AminurAlam](https://github.com/AminurAlam)
- [@JesusChapman](https://github.com/JesusChapman)
- [@T-Dynamos](https://github.com/T-Dynamos)
- [@priyanujgogoi-28](https://github.com/priyanujgogoi-28)
- [@ian4hu](https://github.com/ian4hu)
- [@Mause](https://github.com/Mause)
- [@CHIZI-0618](https://github.com/CHIZI-0618)
- [@Freed-Wu](https://github.com/Freed-Wu)
- [@joakim-noah](https://github.com/joakim-noah)
- [@flosnvjx](https://github.com/flosnvjx)
- [@kawanakaiku](https://github.com/kawanakaiku)
- [@PeroSar](https://github.com/PeroSar)
- [@waruqi](https://github.com/waruqi)
- [@Hax4us](https://github.com/Hax4us)
- [@franciscod](https://github.com/franciscod)
- [@3ls-it](https://github.com/3ls-it)
- [@Dawimpy](https://github.com/Dawimpy)
- [@Juhan280](https://github.com/Juhan280)
- [@kinke](https://github.com/kinke)
- [@pranav10780](https://github.com/pranav10780)
- [@phcoder](https://github.com/phcoder)
- [@PiprTuff](https://github.com/PiprTuff)
- [@shadmansaleh](https://github.com/shadmansaleh)
- [@PChaicot](https://github.com/PChaicot)
- [@kcotugno](https://github.com/kcotugno)
- [@podsvirov](https://github.com/podsvirov)
- [@robertvalik](https://github.com/robertvalik)
- [@richboss](https://github.com/richboss)
- [@tstein](https://github.com/tstein)
- [@schardev](https://github.com/schardev)
- [@alexytomi](https://github.com/alexytomi)
- [@cnjhb](https://github.com/cnjhb)
- [@okhex](https://github.com/okhex)
- [@Rudloff](https://github.com/Rudloff)
- [@IntinteDAO](https://github.com/IntinteDAO)
- [@ravener](https://github.com/ravener)
- [@gavinhoward](https://github.com/gavinhoward)
- [@Deshdeepak1](https://github.com/Deshdeepak1)
- [@leap0x7b](https://github.com/leap0x7b)
- [@qwerty12](https://github.com/qwerty12)
- [@laurentlbm](https://github.com/laurentlbm)
- [@pgaskin](https://github.com/pgaskin)
- [@TheBrokenRail](https://github.com/TheBrokenRail)
- [@dev-bz](https://github.com/dev-bz)
- [@mrsrimar22](https://github.com/mrsrimar22)
- [@togashigreat](https://github.com/togashigreat)
- [@dead10ck](https://github.com/dead10ck)
- [@0x1ACA663](https://github.com/0x1ACA663)
- [@sk0kanik](https://github.com/sk0kanik)
- [@Ludea](https://github.com/Ludea)
- [@craigcomstock](https://github.com/craigcomstock)
- [@fjl](https://github.com/fjl)

### 其他项目致谢

- [proot](https://github.com/proot-me/proot) - 用户空间实现的 chroot
- [proot-distro](https://github.com/termux/proot-distro) - proot 发行版管理器
- [AnyKernel3](https://github.com/osm0sis/AnyKernel3) - 通用内核打包工具 (作者: osm0sis)
- [AOSP](https://source.android.com/) - Android 开源项目
- [Clang/LLVM](https://clang.llvm.org/) - C/C++ 编译器
- [GCC](https://gcc.gnu.org/) - GNU 编译器集合

## 免责声明

本项目仅供学习和研究使用。使用本工具编译和刷入内核可能导致设备损坏，请自行承担风险。

---

**Made with ❤️ by Spring-bulid**

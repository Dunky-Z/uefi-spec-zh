# 概述

---

UEFI 允许通过加载 UEFI 驱动程序和 UEFI 应用程序映像来扩展平台固件。加载 UEFI 驱动程序和 UEFI 应用程序后，它们可以访问所有 UEFI 定义的运行时和启动服务。见图 2-1

---

![启动顺序](../pic/2-1.jpg "启动顺序")

---

UEFI 允许将来自 OS 加载程序和平台固件的引导菜单合并到单个平台固件菜单中。这些平台固件菜单，将允许从 UEFI 引导服务支持的任何引导介质上的任何分区中选择任何 UEFI OS 加载程序。UEFI OS 加载程序可以支持可以出现在用户界面上的多个选项。还可以包括传统引导选项，例如从平台固件引导菜单中的 A: 或 C: 驱动器引导。

UEFI 支持从包含 UEFI 操作系统加载程序或 UEFI 定义的系统分区的媒介引导。UEFI 需要 UEFI 定义的系统分区才能从块设备引导。UEFI 不需要对分区的第一个扇区进行任何更改，因此可以构建媒介在旧架构和 UEFI 平台上启动。

## 引导管理器

## 固件核心

## 调用约定

## 协议

## UEFI 驱动模型

## 要求

本文件是一个架构规范。因此，在实现中保留了最大的灵活度。但是，有一些要求，这个规范的元素必须被实现，以确保操作系统加载器和其他设计成与 UEFI 启动服务一起运行的代码可以依赖一个一致的环境。为了描述这些要求，这个规范被分成了必要的和可选的元素。一般来说，一个可选的元素在与该元素名称相匹配的章节中被完全定义。然而，对于必需的元素，在少数情况下，定义可能不完全包含在为特定元素命名的部分中。在实现必要元素时，应该注意涵盖本规范中定义的与特定元素相关的所有语义。

### 必要元素

表 2-11 列出了所需必要元素。任何符合本规范的系统，都必须实现这些元素。这意味着所有必要的服务功能和协议都必须存在，并且实现必须为所有的调用和参数组合提供规范中定义的全部语义。应用程序、驱动程序或操作系统加载器，他们可以假设所有这些系统都实现了所有的必要要素

系统供应商可能会选择不实现所有要求的元素，例如，在专门的系统配置上，不支持要求的元素所隐含的所有服务和功能。然而，由于大多数应用程序、驱动程序和操作系统加载器的编写是假设所有必要的元素都存在于实现 UEFI 规范的系统上；任何这样的代码都可能需要明确的定制，以运行在对该规范中所要求的元素的不完全实现。

### 平台特定的元素

根据平台所需的特定功能，可以添加或删除许多元素。平台固件开发者需要根据所包含的功能来实现 UEFI 元素。以下是可能的平台特征和每种特征类型所需的要素清单：

1. 如果一个平台包括控制台设备，必须实现`EFI_SIMPLE_TEXT_INPUT_PROTOCOL`、`EFI_SIMPLE_TEXT_INPUT_EX_PROTOCOL`和`EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL`。
2. 如果一个平台包括一个配置基础设施，那么`EFI_HII_DATABASE_PROTOCOL`,`EFI_HII_STRING_PROTOCOL`, `EFI_HII_CONFIG_ROUTING_PROTOCOL`, `EFI_HII_CONFIG_ACCESS_PROTOCOL`是必须的。如果你支持位图字体，你必须支持`EFI_HII_FONT_PROTOCOL`。
3. 如果一个平台包括图形控制台设备，那么必须实现 `EFI_GRAPHICS_OUTPUT_PROTOCOL`、`EFI_EDID_DISCOVERED_PROTOCOL` 和 `EFI_EDID_ACTIVE_PROTOCOL`。为了支持 `EFI_GRAPHICS_OUTPUT_PROTOCOL`，一个平台必须包含一个驱动程序来消费 `EFI_GRAPHICS_OUTPUT_PROTOCOL` 并产生 `EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL`，即使 `EFI_GRAPHICS_OUTPUT_PROTOCOL` 是由一个外部驱动程序产生的。
4. 如果一个平台包括一个指针设备作为其控制台支持的一部分，`EFI_SIMPLE_POINTER_PROTOCOL` 必须被实现。
5. 如果一个平台包括从磁盘设备启动的能力，那么就需要 `EFI_BLOCK_IO_PROTOCOL`、`EFI_DISK_IO_PROTOCOL`、`EFI_SIMPLE_FILE_SYSTEM_PROTOCOL` 以及 `EFI_UNICODE_COLLATION_PROTOCOL`。此外，必须实现对 `MBR`、`GPT` 和 El `Torito` 的分区支持。对于支持 SPC-4 或 ATA8-ACS 命令集安全命令的磁盘设备，还需要 `EFI_STORAGE_SECURITY_COMMAND_PROTOCOL`。（TODO 原文多了下划线）外部驱动程序可以产生块 I/O 协议和 `EFI_STORAGE_SECURITY_COMMAND_PROTOCOL`。所有其他从磁盘设备启动所需的协议必须作为平台的一部分进行。
6. 如果一个平台可以从网络设备 TFTP 启动，那么就需要 `EFI_PXE_BASE_CODE_PROTOCOL`。平台必须准备好在 `EFI_NETWORK_INTERFACE_IDENTIFIER_PROTOCOL(UNDI)`、`EFI_SIMPLE_NETWORK_PROTOCOL` 或 `EFI_MANAGED_NETWORK_PROTOCOL` 中的任何一种上产生这个协议。如果平台包括验证通过网络设备收到的启动镜像的能力。也需要支持映像验证，包括 *`SetupMode`* 等于 0，引导映像的哈希值或映像对应的验证证书存在于'db'变量而不是'dbx'变量中。一个外部驱动可以产生 UNDI 接口。从网络设备启动所需的所有其他协议必须由平台来执行。
7. 如果一个平台支持 UEFI 通用网络应用，那么 `EFI_MANAGED_NETWORK_PROTOCOL`, `EFI_MANAGED_NETWORK_SERVICE_BINDING_PROTOCOL`, `EFI_ARP_PROTOCOL`, `EFI_ARP_SERVICE_BINDING_PROTOCOL`, `EFI_DHCP4_PROTOCOL`, `EFI_DHCP4_SERVICE_BINDING_PROTOCOL`。 `EFI_TCP4_PROTOCOL`, `EFI_TCP4_SERVICE_BINDING_PROTOCOL`, `EFI_IP4_PROTOCOL`, `EFI_IP4_SERVICE_BINDING_PROTOCOL`, `EFI_IP4_CONFIG2_PROTOCOL`, `EFI_UDP4_PROTOCOL` 和 `EFI_UDP4_SERVICE_BINDING_PROTOCOL` 是必需的。如果该平台需要额外的 IPv6 支持，那么需要 `EFI_DHCP6_PROTOCOL、EFI_DHCP6_SERVICE_BINDING_PROTOCOL`、`EFI_TCP6_PROTOCOL`、`EFI_TCP6_SERVICE_BINDING_PROTOCOL`。`EFI_IP6_PROTOCOL`、`EFI_IP6_SERVICE_BINDING_PROTOCOL`、`EFI_IP6_CONFIG_PROTOCOL`、`EFI_UDP6_PROTOCOL` 和 `EFI_UDP6_SERVICE_BINDING_PROTOCOL` 是额外要求的。如果网络应用需要 DNS 功能，`EFI_DNS4_SERVICE_BINDING_PROTOCOL` 和 `EFI_DNS4_PROTOCOL` 是 IPv4 协议栈的必备条件。IPv6 协议栈需要 `EFI_DNS6_SERVICE_BINDING_PROTOCOL` 和 `EFI_DNS6_PROTOCOL`。如果网络环境需要 `TLS` 功能，需要 `EFI_TLS_SERVICE_BINDING_PROTOCOL`、`EFI_TLS_PROTOCOL` 和 `EFI_TLS_CONFIGURATION_PROTOCOL`。如果网络环境需要 `IPSEC` 功能，需要 `EFI_IPSEC_CONFIG_PROTOCOL` 和 `EFI_IPSEC2_PROTOCOL`。如果网络环境需要 VLAN 功能，需要 `EFI_VLAN_CONFIG_PROTOCOL`。
8. 如果一个平台包括一个字节流设备，如 UART，那么 `EFI_SERIAL_IO_PROTOCOL` 必须被实现。
9. 如果一个平台包括 PCI 总线支持，那么 `EFI_PCI_ROOT_BRIDGE_IO_PROTOCOL`，`EFI_PCI_IO_PROTOCOL`，必须被实现。
10. 如果一个平台包括 USB 总线支持，那么必须实现 `EFI_USB2_HC_PROTOCOL` 和 `EFI_USB_IO_PROTOCOL`。一个外部设备可以通过产生一个 USB 主机控制器协议来支持 USB。
11. 如果一个平台包括一个 NVM Express 控制器，那么必须实现 `EFI_NVM_EXPRESS_PASS_THRU_PROTOCOL`。
12. 如果一个平台支持从面向块的 NVM Express 控制器启动，那么必须实现 `EFI_BLOCK_IO_PROTOCOL`。一个外部驱动程序可以产生 `EFI_NVM_EXPRESS_PASS_THRU_PROTOCOL`。从 NVM Express 子系统启动所需的所有其他协议必须由平台携带。
13. 如果一个平台包括一个利用 SCSI 命令包的 I/O 子系统，那么`EFI_EXT_SCSI_PASS_THRU_PROTOCOL`必须被实现。
14. 如果一个平台支持从面向块的 SCSI 外设启动，那么必须实现 `EFI_SCSI_IO_PROTOCOL` 和 `EFI_BLOCK_IO_PROTOCOL`。一个外部驱动程序可以产生 `EFI_EXT_SCSI_PASS_THRU_PROTOCO`L。从 SCSI I/O子系统启动所需的所有其他协议必须由平台携带。
15. 如果一个平台支持从 iSCSI 外围启动，那么必须实现 `EFI_ISCSI_INITIATOR_NAME_PROTOCOL` 和 `EFI_AUTHENTICATION_INFO_PROTOCOL`。
16. 如果一个平台包括调试功能，那么 `EFI_DEBUG_SUPPORT_PROTOCOL`、`EFI_DEBUGPORT_PROTOCOL` 和 EFI 图像信息表必须被实现。
17. 如果一个平台包括将默认驱动程序覆盖到 UEFI 驱动程序模型提供的控制器匹配算法的能力，那么必须实现 `EFI_PLATFORM_DRIVER_OVERRIDE_PROTOCOL`。
18. 如果一个平台包括一个利用 ATA 命令包的 I/O 子系统，那么必须实现`EFI_ATA_PASS_THRU_PROTOCOL`。
19. 如果一个平台支持来自非永久连接到平台的设备的选项 ROM，并且支持验证这些选项 ROM 的能力，那么它必须支持《网络协议-UDP 和 MTFTP》中描述的选项 ROM 验证方法和第 8.1.1 节中描述的验证 EFI 变量。
20. 如果一个平台包括验证 UEFI 图像的能力，并且该平台可能支持一个以上的操作系统加载器，它必须支持网络协议--UDP 和 MTFTP 中描述的方法以及第 8.1.1 节中描述的验证 UEFI 变量。
21. 从 UEFI 规范 2.8 版开始，不再需要 EBC 支持。如果一个 EBC 解释器被实现，那么它必须产生 `EFI_EBC_PROTOCOL` 接口。
22. 如果一个平台包括从网络设备执行基于 HTTP 的启动的能力，那么就需要 `EFI_HTTP_SERVICE_BINDING_PROTOCOL`、`EFI_HTTP_PROTOCOL` 和 `EFI_HTTP_UTILITIES_PROTOCOL`。如果它包括从网络设备执行基于 HTTPS 的启动的能力，除了上述协议，还需要 `EFI_TLS_SERVICE_BINDING_PROTOCOL`、`EFI_TLS_PROTOCOL` 和 `EFI_TLS_CONFIGURATION_PROTOCOL`。如果它包括执行基于 HTTP(S) 的启动和 DNS 功能的能力，那么 IPv4 堆栈需要 `EFI_DNS4_SERVICE_BINDING_PROTOCOL`、`EFI_DNS4_PROTOCOL`；IPv6 堆栈需要 EFI_DNS6_SERVICE_BINDING_PROTOCOL 和 EFI_DNS6_PROTOCOL。
23. 如果一个平台包括从具有 EAP 功能的网络设备执行无线启动的能力，并且如果该平台提供独立的无线 EAP 驱动程序，则需要 `EFI_EAP_PROTOCOL`、`EFI_EAP_CONFIGURATION_PROTOCOL` 和 `EFI_EAP_MANAGEMENT2_PROTOCOL`；如果该平台提供独立的无线请求器，则需要 `EFI_SUPPLICANT_PROTOCOL` 和 `EFI_EAP_CONFIGURATION_PROTOCOL`。如果它包括使用 TLS 功能进行无线启动的能力，那么需要 `EFI_TLS_SERVICE_BINDING_PROTOCOL`、`EFI_TLS_PROTOCOL` 和 `EFI_TLS_CONFIGURATION_PROTOCOL`。
24. 如果一个平台支持经典蓝牙，那么必须实现 `EFI_BLUETOOTH_HC_PROTOCOL`、`EFI_BLUETOOTH_IO_PROTOCOL` 和 `EFI_BLUETOOTH_CONFIG_PROTOCOL`，并且可以实现 `EFI_BLUETOOTH_ATTRIBUTE_PROTOCOL`。如果一个平台支持 Bluetooth Smart (Bluetooth Low Energy)，那么必须实现 `EFI_BLUETOOTH_HC_PROTOCOL`、`EFI_BLUETOOTH_ATTRIBUTE_PROTOCOL` 和 `EFI_BLUETOOTH_LE_CONFIG_PROTOCOL`。如果一个平台同时支持蓝牙经典和蓝牙 LE，那么上述两个要求都应该得到满足。
25. 如果一个平台支持通过 HTTP 或通过带内路径与 BMC 进行 RESTful 通信，那么必须实现 `EFI_REST_PROTOCOL` 或 `EFI_REST_EX_PROTOCOL`。如果 `EFI_REST_EX_PROTOCOL` 被实现，`EFI_REST_EX_SERVICE_BINDING_PROTOCOL` 也必须被实现。如果一个平台支持通过 HTTP 或通过带内路径与 BMC 进行 Redfish 通信，可以实现 `EFI_REDFISH_DISCOVER_PROTOCOL` 和 `EFI_REST_JSON_STRUCTURE_PROTOCOL`。
26. 如果一个平台包括使用硬件功能来创建高质量的随机数的能力，这种能力应该通过 `EFI_RNG_PROTOCOL` 的实例暴露出来，至少有一种 EFI RNG 算法被支持。
27. 如果一个平台允许安装加载选项变量（Boot####，或 Driver####，或 SysPrep####），该平台必须支持和识别变量内所有定义的属性值，并在 `BootOptionSupport` 中报告这些能力。如果一个平台支持安装 Driver####类型的加载选项变量，所有安装的 Driver####变量必须被处理，并在每次启动时加载和初始化指定的驱动程序。而且所有安装的 SysPrep####选项必须在处理 Boot####选项之前被处理。
28. 如果平台支持 UEFI 安全启动，如安全启动和驱动程序签名中所述，平台必须提供第 37.4 节中描述的 PKCS 验证功能。
29. 如果一个平台包括一个利用SD或eMMC命令包的I/O子系统，那么必须实现`EFI_SD_MMC_PASS_THRU_PROTOCOL`。
30. 如果一个平台包括创建/销毁指定的RAM磁盘的能力，EFI_RAM_DISK_PROTOCOL必须被实现，并且这个协议只存在一个实例。
31. 如果一个平台包括一个支持在指定范围内基于硬件擦除的大容量存储设备，那么必须实现 `EFI_ERASE_BLOCK_PROTOCOL`。
32. 如果一个平台包括在调用 ResetSystem 时注册通知的功能，那么必须实现 `EFI_RESET_NOTIFICATION_PROTOCOL`。
33. 如果一个平台包括 UFS 设备，必须实现 `EFI_UFS_DEVICE_CONFIG_PROTOCOL`。
34. 如果一个平台在调用 *`ExitBootServices()`* 后不能支持 `EFI_RUNTIME_SERVICES` 中定义的调用，该平台允许提供这些运行时服务的实现，在运行时调用时返回 `EFI_UNSUPPORTED`。在这样的系统上，应该发布一个 `EFI_RT_PROPERTIES_TABLE` 配置表，描述哪些运行时服务在运行时被支持。
35. 如果平台包括对具有相干内存的 CXL 设备的支持，那么平台必须支持从设备中提取相干设备属性表（CDAT），使用 CXL 数据对象交换服务（如 CXL 2.0 规范中定义的）或安装在该设备上的 EFI_ADAPTER_INFORMATION_PROTOCOL 实例（具有 EFI_ADAPTER_INFO_CDAT_TYPE_GUID 类型）。

**注意**：一些所需的协议实例是由相应的服务绑定协议创建的。例如，`EFI_IP4_PROTOCOL` 是由 EFI_IP4_SERVICE_BINDING_PROTOCOL 创建。详细情况请参考服务绑定协议的相应章节。

### 驱动程序的特定要素

有一些 UEFI 元素可以被添加或删除，这取决于特定驱动程序所需的功能。驱动程序可以由平台固件开发者实现，以支持特定平台的总线和设备。驱动程序也可以由附加卡供应商实现，用于可能被集成到平台硬件中的设备或通过扩展槽添加到平台中的设备。

下面的列表包括可能的驱动程序特性，以及每种特性类型所需的 UEFI 元素。

1. 如果一个驱动程序遵循本规范的驱动程序模型，就必须实现 `EFI_DRIVER_BINDING_PROTOCOL`。强烈建议所有遵循本规范的驱动程序模型的驱动程序也实现 `EFI_COMPONENT_NAME2_PROTOCOL`。
2. 如果一个驱动程序需要配置信息，该驱动程序必须使用 `EFI_HII_DATABASE_PROTOCOL`。驱动程序不应该以其他方式向用户显示信息或向用户请求信息。
3. 如果一个驱动程序需要诊断，必须实现 `EFI_DRIVER_DIAGNOSTICS2_PROTOCOL`。为了支持低启动时间，在正常启动期间限制诊断。耗时的诊断应该推迟到调用 `EFI_DRIVER_DIAGNOSTICS2_PROTOCOL` 时进行。
4. 如果一个总线支持能够为驱动程序提供容器的设备（例如，选项 ROM），那么该总线类型的总线驱动程序必须实现 `EFI_BUS_SPECIFIC_DRIVER_OVERRIDE_PROTOCOL`。
5. 如果为控制台输出设备编写驱动程序，那么必须实现 `EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL`。
6. 如果为图形控制台输出设备编写驱动程序，则必须实现 `EFI_GRAPHICS_OUTPUT_PROTOCOL`、`EFI_EDID_DISCOVERED_PROTOCOL` 和 `EFI_EDID_ACTIVE_PROTOCOL`。
7. 如果为控制台输入设备编写驱动程序，那么必须实现 `EFI_SIMPLE_TEXT_INPUT_PROTOCOL` 和 `EFI_SIMPLE_TEXT_INPUT_EX_PROTOCOL`。
8. 如果为一个指针设备编写驱动程序，那么必须实现 `EFI_SIMPLE_POINTER_PROTOCOL`。
9. 如果为网络设备编写驱动程序，那么必须实现 `EFI_NETWORK_INTERFACE_IDENTIFIER_PROTOCOL`、`EFI_SIMPLE_NETWORK_PROTOCOL` 或 `EFI_MANAGED_NETWORK_PROTOCOL`。如果硬件中支持 VLAN，那么网络设备的驱动程序可以实现 `EFI_VLAN_CONFIG_PROTOCOL`。如果网络设备选择只产生 `EFI_MANAGED_NETWORK_PROTOCOL`，那么网络设备的驱动程序必须实现 `EFI_VLAN_CONFIG_PROTOCOL`。如果为网络设备编写驱动，除了上述协议外，还提供无线功能，`EFI_ADAPTER_INFORMATION_PROTOCOL` 必须实现。如果无线驱动程序不提供用户配置功能，必须实现 `EFI_WIRELESS_MAC_CONNECTION_II_PROTOCOL`。如果无线驱动程序是为提供独立的无线 EAP 驱动程序的平台编写的，则必须实现 `EFI_EAP_PROTOCOL`。
10. 如果为磁盘设备编写驱动程序，那么必须实现 `EFI_BLOCK_IO_PROTOCOL` 和 `EFI_BLOCK_IO2_PROTOCOL`。此外，对于支持 SPC-4 或 ATA8-ACS 命令集安全命令的磁盘设备，必须实现 `EFI_STORAGE_SECURITY_COMMAND_PROTOCOL`。此外，对于在主机存储控制器中支持倾斜加密的设备，必须支持 `EFI_BLOCK_IO_CRYPTO_PROTOCOL`。
11. 如果为磁盘设备编写驱动程序，那么必须实现 `EFI_BLOCK_IO_PROTOCOL` 和 `EFI_BLOCK_IO2_PROTOCOL`。此外，`EFI_STORAGE_SECURITY_COMMAND_PROTOCOL` 必须用于支持 SPC-4 或 ATA8-ACS 命令集安全命令的磁盘设备。
12. 如果为一个不是面向块的设备编写的驱动程序，但它可以提供一个类似文件系统的接口，那么必须实现 `EFI_SIMPLE_FILE_SYSTEM_PROTOCOL`。
13. 如果为 PCI 根桥编写驱动程序，那么 `EFI_PCI_ROOT_BRIDGE_IO_PROTOCOL` 和 `EFI_PCI_IO_PROTOCOL` 必须被实现。
14. 如果为 NVM Express 控制器编写驱动程序，那么必须实现 `EFI_NVM_EXPRESS_PASS_THRU_PROTOCOL`。
15. 如果为 USB 主机控制器编写驱动程序，那么必须实现 `EFI_USB2_HC_PROTOCOL` 和 `EFI_USB_IO_PROTOCOL`。如果为 USB 主机控制器编写驱动程序，那么必须实现该。
16. 如果为 SCSI 控制器编写驱动程序，那么必须实现 `EFI_EXT_SCSI_PASS_THRU_PROTOCOL`。
17. 如果一个驱动程序是数字签名的，它必须在 PE/COFF 图像中嵌入数字签名，如第 1691 页的 "嵌入式签名"所述。
18. 如果为一个不是面向块的设备、基于文件系统的设备或控制台设备的启动设备编写驱动程序，那么必须实现 `EFI_LOAD_FILE2_PROTOCOL`。
19. 如果一个驱动遵循本规范的驱动模型，并且该驱动想为用户产生警告或错误信息，那么必须使用 `EFI_DRIVER_HEALTH_PROTOCOL` 来产生这些信息。启动管理器可以选择向用户显示这些信息。
20. 如果一个驱动程序遵循本规范的驱动程序模型，并且该驱动程序需要执行不属于正常初始化序列的修复操作，并且该修复操作需要很长一段时间，那么必须使用 `EFI_DRIVER_HEALTH_PROTOCOL` 来提供修复功能。如果 Boot Manager 检测到一个需要修复操作的启动设备，那么 Boot Manager 必须使用 `EFI_DRIVER_HEALTH_PROTOCOL` 来执行修复操作。在驱动器执行修复操作时，Boot Manager 可以选择性地显示进度指示器。
21. 如果一个驱动程序遵循本规范的驱动程序模型，并且该驱动程序要求用户在使用该驱动程序所管理的启动设备之前进行软件和/或硬件配置的改变，那么必须产生 `EFI_DRIVER_HEALTH_PROTOCOL`。如果 Boot Manager 检测到一个引导设备需要软件和/或硬件配置的改变以使该引导设备可用，那么 Boot Manager 可以选择允许用户进行这些配置的改变。
22. 如果为一个 ATA 控制器编写驱动程序，那么必须实现 `EFI_ATA_PASS_THRU_PROTOCOL`。
23. 如果一个驱动程序遵循本规范的驱动程序模型，并且在为控制器选择最佳驱动程序时，该驱动程序希望以高于总线特定驱动程序覆盖协议的优先级使用，那么 `EFI_DRIVER_FAMILY_OVERRIDE_PROTOCOL` 必须与 `EFI_DRIVER_BINDING_PROTOCOL` 产生在同一把手上。
24. 如果一个驱动程序支持外部代理或应用程序的固件管理，那么必须使用 `EFI_FIRMWARE_MANAGEMENT_PROTOCOL` 来支持固件管理。
25. 如果一个驱动程序遵循本规范的驱动程序模型，并且一个驱动程序是第 2.5 节中定义的设备驱动程序，它必须通过父级总线驱动程序产生的总线抽象协议执行总线事务。因此，符合 PCI 规范的设备的驱动程序必须使用 `EFI_PCI_IO_PROTOCOL` 进行所有的 PCI 内存空间、PCI I/O、PCI配置空间和DMA操作。
26. 如果为经典蓝牙控制器编写驱动程序，那么必须实现 `EFI_BLUETOOTH_HC_PROTOCOL`、`EFI_BLUETOOTH_IO_PROTOCOL` 和 `EFI_BLUETOOTH_CONFIG_PROTOCOL`，并且可以实现 `EFI_BLUETOOTH_ATTRIBUTE_PROTOCOL`。如果是为 Bluetooth Smart（Bluetooth Low Energy）控制器编写的驱动程序，则必须实现 `EFI_BLUETOOTH_HC_PROTOCOL`、`EFI_BLUETOOTH_ATTRIBUTE_PROTOCOL` 和 `EFI_BLUETOOTH_LE_CONFIG_PROTOCOL`。如果一个驱动程序同时支持蓝牙经典和蓝牙 LE，那么上述两个要求都应该得到满足。
27. 如果为 SD 控制器或 eMMC 控制器编写驱动程序，那么必须实现 `EFI_SD_MMC_PASS_THRU_PROTOCOL`。
28. 如果为 UFS 设备编写驱动程序，那么必须实现 `EFI_UFS_DEVICE_CONFIG_PROTOCOL`。

### 在其他地方发布的对本规范的扩展

随着时间的推移，本规范已被扩展，包括对新设备和技术的支持。正如该规范的名称所暗示的那样，其定义的初衷是为固件接口创建一个可扩展的基线，而不需要在本规范的主体中包含扩展。

本规范的读者可能会发现，本规范没有处理某个功能或设备类型。这并不一定意味着在声称符合本规范的实现中，没有约定的 "标准 "方式来支持该特征或设备。有时，其他标准组织发布他们自己的扩展可能更合适，这些扩展旨在与这里的定义协同使用。例如，与等待本规范的修订相比，这样做可以更及时地支持新的功能，或者说，这种支持是由一个在该主题领域具有特殊专长的团体来定义的。因此，建议读者在创建自己的扩展之前，向适当的标准小组询问，以确定是否已经存在适当的扩展出版物。

举例来说，在撰写本规范时，UEFI 论坛知道有一些扩展出版物与本规范兼容，并为其设计。这些扩展包括：

*基于 Itanium®架构的服务器的开发者接口指南*：由 DIG64 小组发布和主持（见 "基于 Itanium®架构的服务器的开发者接口指南 "标题下的 "与 UEFI 相关的文件链接"（<http://uefi.org/> uefi））。该文件是一套技术指南，定义了基于 Itanium™的服务器的硬件、固件和操作系统的兼容性。

*TCG EFI 平台规范*：由 Trusted Computing Group 发布和主持（见 "TCG EFI 平台规范 "标题下的 "UEFI 相关文件链接"（<http://uefi.org/uefi>）。这份文件是关于启动 EFI 平台和在该平台上启动操作系统的过程。具体来说，本规范包含了将启动事件测量到 TPM> PCR 和将启动事件条目添加到事件日志的要求。

*TCG EFI 协议规范*：由 Trusted Computing Group 发布和主持（参见 "UEFI 相关文件的链接"（<http://uefi.org/uefi>）。. 本文件定义了 EFI 平台上 TPM 的标准接口。

其他的扩展文件可能存在于 UEFI 论坛的视野之外，也可能是在本文件最后一次修订之后创建的。
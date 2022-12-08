# EFI System Table

本节介绍 UEFI 映像的入口点以及传递到该入口点的参数。符合本规范的固件可以加载和执行三种类型的 UEFI 镜像。它们是 UEFI 应用程序（参见第 2.1.2 节）、UEFI 引导服务驱动程序（参见第 2.1.4 节）和 UEFI 运行时驱动程序（参见第 2.1.4 节）。UEFI 应用程序包括 UEFI OS 加载程序（参见第 2.1.3 节）。这三种镜像类型的入口点没有区别。

## UEFI Image Entry Point

传递给图像的最重要参数是指向系统表的指针。该指针是 EFI_IMAGE_ENTRY_POINT（参见下面的定义），它是 UEFI 映像的主要入口点。系统表包含指向活动控制台设备的指针、指向启动服务表的指针、指向运行时服务表的指针以及指向系统配置表（如 ACPI、SMBIOS 和 SAL 系统表）列表的指针。本节详细介绍系统表。

**EFI_IMAGE_ENTRY_POINT**

**概述**

这是 UEFI 映像的主要入口点。此入口点对于 UEFI 应用程序和 UEFI 驱动程序是相同的。

**原型**

```C
typedef
EFI_STATUS
(EFIAPI *EFI_IMAGE_ENTRY_POINT) (
IN EFI_HANDLE ImageHandle,
IN EFI_SYSTEM_TABLE *SystemTable
);
```

**参数**

- ImageHandle:为 UEFI 映像分配的固件句柄
- SystemTable:指向 EFI 系统表的指针

**描述**

此函数是 EFI 映像的入口点。EFI 映像由 EFI 引导服务`EFI_BOOT_SERVICES.LoadImage()` 加载并重新定位在系统内存中。EFI 映像通过 EFI 引导服务 `EFI_BOOT_SERVICES.StartImage()` 调用。

传递给图像的最重要参数是指向系统表的指针。这个指针是 EFI_IMAGE_ENTRY_POINT（见下面的定义），UEFI Image 的主要入口点。系统表包含指向活动控制台设备的指针、指向引导服务表的指针、指向运行时服务表的指针以及指向系统配置表列表（例如 ACPI、SMBIOS 和 SAL 系统表）的指针。本节详细介绍系统表。

ImageHandle 是固件分配的句柄，用于在各种功能上识别图像。该句柄还支持图像可以使用的一种或多种协议。所有图像都支持 `EFI_LOADED_IMAGE_PROTOCOL` 和 `EFI_LOADED_IMAGE_DEVICE_PATH_PROTOCOL`，它们返回图像的源位置、图像的内存位置、图像的加载选项等。确切的 `EFI_LOADED_IMAGE_PROTOCOL` 和 `EFI_LOADED_IMAGE_DEVICE_PATH_PROTOCOL` 结构在第 9 节中定义。

如果 UEFI 映像是不是 UEFI 操作系统加载程序的 UEFI 应用程序，则该应用程序将执行并返回或调用 EFI 引导服务 `EFI_BOOT_SERVICES.Exit()`。UEFI 应用程序在退出时总是从内存中卸载，并将其返回状态返回给启动该 UEFI 应用程序的组件。

如果 UEFI 映像是 UEFI 操作系统加载程序，则 UEFI 操作系统加载程序将执行并返回，调用 EFI 引导服务 `Exit()`，或调用 EFI 引导服务 `EFI_BOOT_SERVICES.ExitBootServices()`。如果 EFI OS Loader 返回或调用 `Exit()`，则 OS 加载失败，EFI OS Loader 从内存中卸载，控制权返回到尝试启动 UEFI OS Loader 的组件。如果调用了 `ExitBootServices()`，那么 UEFI OS Loader 已经控制了平台，EFI 将不会重新获得系统的控制权，直到平台被重置。重置平台的一种方法是通过 EFI 运行时服务 `ResetSystem()`。

如果 UEFI 映像是 UEFI 驱动程序，则 UEFI 驱动程序将执行并返回或调用 Boot Service `Exit()`。如果 UEFI 驱动程序返回错误，则驱动程序将从内存中卸载。如果 UEFI 驱动程序返回 `EFI_SUCCESS`，则它会驻留在内存中。如果 UEFI 驱动程序不遵循 UEFI 驱动程序模型，则它会执行任何必需的初始化并在返回之前安装其协议服务。如果驱动程序确实遵循 UEFI 驱动程序模型，则不允许入口点接触任何设备硬件。相反，入口点需要在 UEFI 驱动程序的 `ImageHandle` 上创建和安装 `EFI_DRIVER_BINDING_PROTOCOL`（请参阅第 11.1 节）。如果此过程完成，则返回 `EFI_SUCCESS`。如果资源不可用于完成 UEFI 驱动程序初始化，则返回 `EFI_OUT_OF_RESOURCES`。

**返回的状态码**

- EFI_SUCCESS：驱动程序已初始化。
- EFI_OUT_OF_RESOURCES：由于缺乏资源，请求无法完成。

## EFI 表头

数据类型 EFI_TABLE_HEADER 是所有标准 EFI 表类型之前的数据结构。它包括对每个表类型唯一的签名、可以在扩展添加到 EFI 表类型时更新的表修订以及一个 32 位 CRC，因此 EFI 表类型的消费者可以验证 EFI 表类型的内容 EFI 表。

**EFI_TABLE_HEADER**

**概述**

在所有标准 EFI 表类型之前的数据结构。

**原型**

```C
typedef struct {
    UINT64 Signature;
    UINT32 Revision;
    UINT32 HeaderSize;
    UINT32 CRC32;
    UINT32 Reserved;
} EFI_TABLE_HEADER;
```

**参数**

- Signature:标识后面的表类型的 64 位签名。已为 EFI 系统表、EFI 引导服务表和 EFI 运行时服务表生成唯一签名。
- Revision:此表符合的 EFI 规范的修订版。该字段的高 16 位包含主修订值，低 16 位包含次修订值。次要修订值是二进制编码的十进制数，并且限制在 00..99 的范围内。
  - 当打印或显示时，UEFI 规范修订被称为（主要修订）。（次要修订上位小数）。（次要修订小数下位）或（主要修订）。（次要修订小数点上位）如果次要修订小数下位设置为 0。例如
  - 具有修订值 ((2<<16) | (30)) 的规范将称为 2.3
  - 具有修订值 ((2<<16) | (31)) 的规范将称为 2.3.1
- HeaderSize:整个表的大小（以字节为单位），包括 EFI_TABLE_HEADER。
- CRC32：整个表的 32 位 CRC。通过将此字段设置为 0 并计算 HeaderSize 字节的 32 位 CRC 来计算此值
- Reserved：必须设置为 0 的保留字段。

**描述**

注：EFI 系统表、运行时表和引导服务表中的功能可能会随时间发生变化。每个表中的第一个字段是 EFI_TABLE_HEADER。当新的能力和功能被添加到表中的功能时，此标头的修订字段会增加。检查功能时，代码应验证 Revision 是否大于或等于将功能添加到 UEFI 规范时表的修订级别。

注：除非另有说明，否则 UEFI 使用标准 CCITT32 CRC 算法进行 CRC 计算，其种子多项式值为 `0x04c11db7`。

注：系统表、运行时服务表和引导服务表的大小可能会随着时间的推移而增加。始终使用 `EFI_TABLE_HEADER` 的 `HeaderSize` 字段来确定这些表的大小非常重要。

## EFI 系统表

UEFI 使用 EFI 系统表，它包含指向运行时和启动服务表的指针。这个表的定义在下面的代码片段中显示。除了表头，服务表中的所有元素都是指向第 7 节和第 8 节中定义的函数的指针。在调用 `EFI_BOOT_SERVICES.ExitBootServices()` 之前，EFI 系统表的所有字段都是有效的。在操作系统通过调用 `ExitBootServices()` 控制平台后，只有 Hdr、`FirmwareVendor`、`FirmwareRevision`、`RuntimeServices`、`NumberOfTableEntries` 和 `ConfigurationTable` 字段有效

**EFI_SYSTEM_TABLE**

**概述**

包含指向运行时和引导服务表的指针。

**相关定义**

```C
#define EFI_SYSTEM_TABLE_SIGNATURE 0x5453595320494249
#define EFI_2_90_SYSTEM_TABLE_REVISION ((2<<16) | (90))
#define EFI_2_80_SYSTEM_TABLE_REVISION ((2<<16) | (80))
#define EFI_2_70_SYSTEM_TABLE_REVISION ((2<<16) | (70))
#define EFI_2_60_SYSTEM_TABLE_REVISION ((2<<16) | (60))
#define EFI_2_50_SYSTEM_TABLE_REVISION ((2<<16) | (50))
#define EFI_2_40_SYSTEM_TABLE_REVISION ((2<<16) | (40))
#define EFI_2_31_SYSTEM_TABLE_REVISION ((2<<16) | (31))
#define EFI_2_30_SYSTEM_TABLE_REVISION ((2<<16) | (30))
#define EFI_2_20_SYSTEM_TABLE_REVISION ((2<<16) | (20))
#define EFI_2_10_SYSTEM_TABLE_REVISION ((2<<16) | (10))
#define EFI_2_00_SYSTEM_TABLE_REVISION ((2<<16) | (00))
#define EFI_1_10_SYSTEM_TABLE_REVISION ((1<<16) | (10))
#define EFI_1_02_SYSTEM_TABLE_REVISION ((1<<16) | (02))
#define EFI_SPECIFICATION_VERSION EFI_SYSTEM_TABLE_REVISION
#define EFI_SYSTEM_TABLE_REVISION EFI_2_90_SYSTEM_TABLE_REVISION
typedef struct {
    EFI_TABLE_HEADER Hdr;
    CHAR16 *FirmwareVendor;
    UINT32 FirmwareRevision;
    EFI_HANDLE ConsoleInHandle;
    EFI_SIMPLE_TEXT_INPUT_PROTOCOL *ConIn;
    EFI_HANDLE ConsoleOutHandle;
    EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL *ConOut;
    EFI_HANDLE StandardErrorHandle;
    EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL *StdErr;
    EFI_RUNTIME_SERVICES *RuntimeServices;
    EFI_BOOT_SERVICES *BootServices;
    UINTN NumberOfTableEntries;
    EFI_CONFIGURATION_TABLE *ConfigurationTable;
    } EFI_SYSTEM_TABLE;
```

参数

- Hdr:EFI 系统表的表头。此标头包含 `EFI_SYSTEM_TABLE_SIGNATURE` 和 `EFI_SYSTEM_TABLE_REVISION` 值以及 `EFI_SYSTEM_TABLE` 结构的大小和 32 位 CRC，以验证 EFI 系统表的内容是否有效
- FirmwareVendor:指向空终止字符串的指针，该字符串标识为平台生产系统固件的供应商
- FirmwareRevision:固件供应商特定值，用于标识平台的系统固件修订版。
- ConsoleInHandle:活动控制台输入设备的句柄。此句柄必须支持 `EFI_SIMPLE_TEXT_INPUT_PROTOCOL` 和 `EFI_SIMPLE_TEXT_INPUT_EX_PROTOCOL`。如果没有活动的控制台，这些协议必须仍然存在。
- ConIn:指向与 ConsoleInHandle 关联的 `EFI_SIMPLE_TEXT_INPUT_PROTOCOL` 接口的指针。
- ConsoleOutHandle:活动控制台输出设备的句柄。此句柄必须支持 `EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL`。如果没有活动控制台，则此协议必须仍然存在
- ConOut:指向与 ConsoleOutHandle 关联的 `EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL` 接口的指针
- StandardErrorHandle:活动标准错误控制台设备的句柄。此句柄必须支持 `EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL`。如果没有活动控制台，则此协议必须仍然存在
- StdErr:指向与 `StandardErrorHandle` 关联的 `EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL` 接口的指针
- RuntimeServices:指向 EFI 运行时服务表的指针。请参阅第 4.5 节。
- BootServices:指向 EFI 引导服务表的指针。请参阅第 4.4 节。
- NumberOfTableEntries:缓冲区 `ConfigurationTable` 中系统配置表的个数
- ConfigurationTable:指向系统配置表的指针。表中的条目数是 `NumberOfTableEntries`。

## EFI Boot Services Table

UEFI 使用 EFI 引导服务表，其中包含表头和指向所有引导服务的指针。该表的定义显示在以下代码片段中。除表头外，EFI 引导服务表中的所有元素都是函数指针的原型，指向第 7 节中定义的函数。在操作系统通过调用控制平台后，此表中的函数指针无效 `EFI_BOOT_SERVICES.ExitBootServices()`。

**EFI_BOOT_SERVICES**

**概述**

包含表头和指向所有引导服务的指针。

**相关定义**

```C
#define EFI_BOOT_SERVICES_SIGNATURE 0x56524553544f4f42
#define EFI_BOOT_SERVICES_REVISION EFI_SPECIFICATION_VERSION
typedef struct {
    EFI_TABLE_HEADER Hdr;
    //
    // Task Priority Services
    //
    EFI_RAISE_TPL RaiseTPL; // EFI 1.0+
    EFI_RESTORE_TPL RestoreTPL; // EFI 1.0+
    //
    // Memory Services
    //
    EFI_ALLOCATE_PAGES AllocatePages; // EFI 1.0+
    EFI_FREE_PAGES FreePages; // EFI 1.0+
    EFI_GET_MEMORY_MAP GetMemoryMap; // EFI 1.0+
    EFI_ALLOCATE_POOL AllocatePool; // EFI 1.0+
    EFI_FREE_POOL FreePool; // EFI 1.0+
    //
    // Event & Timer Services
    //
    EFI_CREATE_EVENT CreateEvent; // EFI 1.0+
    EFI_SET_TIMER SetTimer; // EFI 1.0+
    EFI_WAIT_FOR_EVENT WaitForEvent; // EFI 1.0+
    EFI_SIGNAL_EVENT SignalEvent; // EFI 1.0+
    EFI_CLOSE_EVENT CloseEvent; // EFI 1.0+
    EFI_CHECK_EVENT CheckEvent; // EFI 1.0+
    //
    // Protocol Handler Services
    //
    EFI_INSTALL_PROTOCOL_INTERFACE InstallProtocolInterface; // EFI 1.0+
    EFI_REINSTALL_PROTOCOL_INTERFACE ReinstallProtocolInterface; // EFI 1.0+
    EFI_UNINSTALL_PROTOCOL_INTERFACE UninstallProtocolInterface; // EFI 1.0+
    EFI_HANDLE_PROTOCOL HandleProtocol; // EFI 1.0+
    VOID* Reserved; // EFI 1.0+
    EFI_REGISTER_PROTOCOL_NOTIFY RegisterProtocolNotify; // EFI 1.0+
    EFI_LOCATE_HANDLE LocateHandle; // EFI 1.0+
    EFI_LOCATE_DEVICE_PATH LocateDevicePath; // EFI 1.0+
    EFI_INSTALL_CONFIGURATION_TABLE InstallConfigurationTable; // EFI 1.0+
    //
    // Image Services
    //
    EFI_IMAGE_LOAD LoadImage; // EFI 1.0+
    EFI_IMAGE_START StartImage; // EFI 1.0+
    EFI_EXIT Exit; // EFI 1.0+
    EFI_IMAGE_UNLOAD UnloadImage; // EFI 1.0+
    EFI_EXIT_BOOT_SERVICES ExitBootServices; // EFI 1.0+
    //
    // Miscellaneous Services
    //
    EFI_GET_NEXT_MONOTONIC_COUNT GetNextMonotonicCount; // EFI 1.0+
    EFI_STALL Stall; // EFI 1.0+
    EFI_SET_WATCHDOG_TIMER SetWatchdogTimer; // EFI 1.0+
    //
    // DriverSupport Services
    //
    EFI_CONNECT_CONTROLLER ConnectController; // EFI 1.1
    EFI_DISCONNECT_CONTROLLER DisconnectController;// EFI 1.1+
    //
    // Open and Close Protocol Services
    //
    EFI_OPEN_PROTOCOL OpenProtocol; // EFI 1.1+
    EFI_CLOSE_PROTOCOL CloseProtocol; // EFI 1.1+
    EFI_OPEN_PROTOCOL_INFORMATION OpenProtocolInformation; // EFI 1.1+
    //
    // Library Services
    //
    EFI_PROTOCOLS_PER_HANDLE ProtocolsPerHandle; // EFI 1.1+
    EFI_LOCATE_HANDLE_BUFFER LocateHandleBuffer; // EFI 1.1+
    EFI_LOCATE_PROTOCOL LocateProtocol; // EFI 1.1+
    EFI_INSTALL_MULTIPLE_PROTOCOL_INTERFACES
    InstallMultipleProtocolInterfaces; // EFI 1.1+
    EFI_UNINSTALL_MULTIPLE_PROTOCOL_INTERFACES
    UninstallMultipleProtocolInterfaces; // EFI 1.1+
    //
    // 32-bit CRC Services
    //
    EFI_CALCULATE_CRC32 CalculateCrc32; // EFI 1.1+
    //
    // Miscellaneous Services
    //
    EFI_COPY_MEM CopyMem; // EFI 1.1+
    EFI_SET_MEM SetMem; // EFI 1.1+
    EFI_CREATE_EVENT_EX CreateEventEx; // UEFI 2.0+
} EFI_BOOT_SERVICES;
```

**参数**

- Hdr EFI 引导服务表的表头。此标头包含 `EFI_BOOT_SERVICES_SIGNATURE` 和 `EFI_BOOT_SERVICES_REVISION` 值以及 `EFI_BOOT_SERVICES` 结构的大小和 32 位 CRC，以验证 EFI 引导服务表的内容是否有效。
- RaiseTPL 提高任务优先级。
- RestoreTPL 恢复/降低任务优先级。
- AllocatePages 分配特定类型的页面。
- FreePages 释放分配的页面。
- GetMemoryMap 返回当前引导服务内存映射和内存映射键。
- AllocatePool 分配特定类型的池。
- FreePool 释放分配的池。
- CreateEvent 创建通用事件结构。
- SetTimer 设置在特定时间发出信号的事件。
- WaitForEvent 停止执行，直到发出事件信号。
- SignalEvent 发出事件信号。
- CloseEvent 关闭和释放事件结构。
- CheckEvent 检查事件是否处于信号状态。
- InstallProtocolInterface 在设备句柄上安装协议接口。
- ReinstallProtocolInterface 在设备句柄上重新安装协议接口。
- UninstallProtocolInterface 从设备句柄中删除协议接口。
- HandleProtocol 查询句柄以确定它是否支持指定的协议。保留 保留。必须为 NULL。
- RegisterProtocolNotify 注册一个事件，每当为指定协议安装接口时，该事件就会发出信号。
- LocateHandle 返回支持指定协议的句柄数组。
- LocateDevicePath 定位设备路径上支持指定协议的所有设备，并将句柄返回到距离该路径最近的设备。
- InstallConfigurationTable 在 EFI 系统表中添加、更新或删除配置表。
- LoadImage 将 EFI 图像加载到内存中。
- StartImage 将控制转移到加载图像的入口点。退出 退出图像的入口点。
- UnloadImage 卸载图像。
- ExitBootServices 终止引导服务。
- GetNextMonotonicCount 返回平台的单调递增计数。停止处理器。
- SetWatchdogTimer 重置和设置引导服务期间使用的看门狗定时器。
- ConnectController 使用一组优先规则来找到最佳驱动程序集来管理控制器。
- DisconnectController 通知一组驱动程序停止管理控制器。
- OpenProtocol 将元素添加到使用协议接口的代理列表中。
- CloseProtocol 从使用协议接口的代理列表中删除元素。
- OpenProtocolInformation 检索当前使用协议接口的代理列表。
- ProtocolsPerHandle 检索句柄上安装的协议列表。返回缓冲区是自动分配的。
- LocateHandleBuffer 从句柄数据库中检索满足搜索条件的句柄列表。返回缓冲区是自动分配的。
- LocateProtocol 在句柄数据库中查找支持所请求协议的第一个句柄。
- InstallMultipleProtocolInterfaces 在句柄上安装一个或多个协议接口。
- UninstallMultipleProtocolInterfaces 从句柄中卸载一个或多个协议接口。
- CalculateCrc32 计算并返回数据缓冲区的 32 位 CRC。
- CopyMem 将一个缓冲区的内容复制到另一个缓冲区。
- SetMem 用指定值填充缓冲区。
- CreateEventEx 创建事件结构作为事件组的一部分

## EFI Runtime Services Table

UEFI 使用 EFI 运行时服务表，其中包含表头和指向所有运行时服务的指针。该表的定义显示在以下代码片段中。除表头外，EFI 运行时服务表中的所有元素都是指向第 8 节中定义的函数的函数指针的原型。与 EFI 引导服务表不同，此表及其包含的函数指针在 UEFI 操作系统加载程序和操作系统通过调用 `EFI_BOOT_SERVICES.ExitBootServices()`控制平台后有效。如果操作系统调用 `SetVirtualAddressMap()`，则此表中的函数指针将固定为指向新的虚拟映射入口点。

**EFI_RUNTIME_SERVICES**

**概述**

包含表头和指向所有运行时服务的指针。

**相关定义**

```C
#define EFI_RUNTIME_SERVICES_SIGNATURE 0x56524553544e5552
#define EFI_RUNTIME_SERVICES_REVISION EFI_SPECIFICATION_VERSION
typedef struct {
    EFI_TABLE_HEADER Hdr;
    //
    // Time Services
    //
    EFI_GET_TIME GetTime;
    EFI_SET_TIME SetTime;
    EFI_GET_WAKEUP_TIME GetWakeupTime;
    EFI_SET_WAKEUP_TIME SetWakeupTime;
    //
    // Virtual Memory Services
    //
    EFI_SET_VIRTUAL_ADDRESS_MAP SetVirtualAddressMap;
    EFI_CONVERT_POINTER ConvertPointer;
    //
    // Variable Services
    //
    EFI_GET_VARIABLE GetVariable;
    EFI_GET_NEXT_VARIABLE_NAME GetNextVariableName;
    EFI_SET_VARIABLE SetVariable;
    //
    // Miscellaneous Services
    //
    EFI_GET_NEXT_HIGH_MONO_COUNT GetNextHighMonotonicCount;
    EFI_RESET_SYSTEM ResetSystem;
    //
    // UEFI 2.0 Capsule Services
    //
    EFI_UPDATE_CAPSULE UpdateCapsule;
    EFI_QUERY_CAPSULE_CAPABILITIES QueryCapsuleCapabilities;
    //
    // Miscellaneous UEFI 2.0 Service
    //
    EFI_QUERY_VARIABLE_INFO QueryVariableInfo;
} EFI_RUNTIME_SERVICES;
```

**参数**

- Hdr EFI 运行时服务表的表头。此标头包含 `EFI_RUNTIME_SERVICES_SIGNATURE` 和 `EFI_RUNTIME_SERVICES_REVISION` 值以及 `EFI_RUNTIME_SERVICES` 结构的大小和 32 位 CRC，以验证 EFI 运行时服务表的内容是否有效。
- GetTime 返回当前时间和日期，以及平台的计时功能。
- SetTime 设置当前本地时间和日期信息。
- GetWakeupTime 返回当前的唤醒闹钟设置。
- SetWakeupTime 设置系统唤醒闹钟时间。
- SetVirtualAddressMap 由 UEFI 操作系统加载程序用于从物理寻址转换为虚拟寻址。
- ConvertPointer 由 EFI 组件用来在切换到虚拟寻址时转换内部指针。
- GetVariable 返回变量的值。
- GetNextVariableName 枚举当前变量名。
- SetVariable 设置变量的值。
- GetNextHighMonotonicCount 返回平台单调计数器的下一个高 32 位。
- ResetSystem 重置整个平台。
- UpdateCapsule 将胶囊传递给具有虚拟和物理映射的固件。
- QueryCapsuleCapabilities 返回是否可以通过 UpdateCapsule() 支持胶囊。
- QueryVariableInfo 返回有关 EFI 变量存储的信息

## EFI Configuration Table & Properties Table

EFI 配置表是 EFI 系统表中的 `ConfigurationTable` 字段。此表包含一组 GUID 指针对。该表的每个元素都由下面的 `EFI_CONFIGURATION_TABLE` 结构描述。配置表的类型数量预计会随着时间的推移而增长。这就是使用 GUID 来标识配置表类型的原因。EFI 配置表最多包含每种表类型的一次实例。

**EFI_CONFIGURATION_TABLE**

**概述**

包含一组 GUID/指针对，由 EFI 系统表中的 ConfigurationTable 字段组成

**相关定义**

```C
typedef struct{
    EFI_GUID VendorGuid;
    VOID *VendorTable;
} EFI_CONFIGURATION_TABLE;
```

**参数**

- VendorGuid 唯一标识系统配置表的 128 位 GUID 值。
- VendorTable 指向与 `VendorGuid` 关联的表的指针。用于存储表的内存类型以及该指针在运行时是物理地址还是虚拟地址（当调用 `SetVirtualAddressMap()` 时，表中报告的特定地址是否得到修复）由 `VendorGuid` 确定。除非另有说明，否则表缓冲区的内存类型由第 2 章调用约定部分中规定的指南定义。定义 VendorTable 的规范有责任指定额外的内存类型要求（如果有）以及是否转换表中报告的地址。任何所需的地址转换都是发布相应配置表的驱动程序的责任。指向与 VendorGuid 关联的表的指针。这个指针在运行时是物理地址还是虚拟地址由 `VendorGuid` 决定。与给定 `VendorTable` 指针关联的 `VendorGuid` 定义在调用 `SetVirtualAddressMap()` 时表中报告的特定地址是否得到修复。定义 `VendorTable` 的规范有责任指定是否转换表中报告的地址。

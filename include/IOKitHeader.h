#define IOHIDEventFieldBase(type) (type << 16)

enum {
    kIOHIDEventTypeNULL,
    kIOHIDEventTypeVendorDefined,
    kIOHIDEventTypeButton,
    kIOHIDEventTypeKeyboard,
    kIOHIDEventTypeTranslation,
    kIOHIDEventTypeRotation,
    kIOHIDEventTypeScroll,
    kIOHIDEventTypeScale,
    kIOHIDEventTypeZoom,
    kIOHIDEventTypeVelocity,
    kIOHIDEventTypeOrientation,
    kIOHIDEventTypeDigitizer,
    kIOHIDEventTypeAmbientLightSensor,
    kIOHIDEventTypeAccelerometer,
    kIOHIDEventTypeProximity,
    kIOHIDEventTypeTemperature,
    kIOHIDEventTypeSwipe,
    kIOHIDEventTypeMouse,
    kIOHIDEventTypeProgress,
    kIOHIDEventTypeCount
};
typedef uint32_t IOHIDEventType;

enum {
    kIOHIDEventFieldDigitizerX = IOHIDEventFieldBase(kIOHIDEventTypeDigitizer),
    kIOHIDEventFieldDigitizerY,
    kIOHIDEventFieldDigitizerZ,
    kIOHIDEventFieldDigitizerButtonMask,
    kIOHIDEventFieldDigitizerType,
    kIOHIDEventFieldDigitizerIndex,
    kIOHIDEventFieldDigitizerIdentity,
    kIOHIDEventFieldDigitizerEventMask,
    kIOHIDEventFieldDigitizerRange,
    kIOHIDEventFieldDigitizerTouch,
    kIOHIDEventFieldDigitizerPressure,
    kIOHIDEventFieldDigitizerBarrelPressure,
    kIOHIDEventFieldDigitizerTwist,
    kIOHIDEventFieldDigitizerTiltX,
    kIOHIDEventFieldDigitizerTiltY,
    kIOHIDEventFieldDigitizerAltitude,
    kIOHIDEventFieldDigitizerAzimuth,
    kIOHIDEventFieldDigitizerQuality,
    kIOHIDEventFieldDigitizerDensity,
    kIOHIDEventFieldDigitizerIrregularity,
    kIOHIDEventFieldDigitizerMajorRadius,
    kIOHIDEventFieldDigitizerMinorRadius,
    kIOHIDEventFieldDigitizerCollection,
    kIOHIDEventFieldDigitizerCollectionChord,
    kIOHIDEventFieldDigitizerChildEventMask
};

typedef uint32_t IOHIDEventField;

#ifndef KERNEL
/*!
	@typedef IOHIDFloat
*/
#ifdef __LP64__
typedef double IOHIDFloat;
#else
typedef float IOHIDFloat;
#endif
#endif

typedef struct __IOHIDService
#if 0
{
  CFRuntimeBase _base;	// 0, 4
  CFTypeRef client;	// 8
  io_service_t service;	// c
  void** pluginInterface1;	// 10; GUID = D12C833F-B15B-11DA-902D-0014519758EF
  void** pluginInterface2;	// 14;
  IOCFPlugInInterface** interface;	// 18
  CFRunLoopRef runloop;	// 1c
  CFStringRef mode;	// 20
  IONotificationPortRef notify;	// 24
  CFMutableSetRef removalNotifications;	// 2c
  void* eventTarget;	// 30
  void* eventRefcon;	// 34
  IOHIDServiceEventCallback eventCallback;	// 38
  uint32_t previousButtonMask;	// 3c
}
#endif
* IOHIDServiceRef;

typedef struct __IOHIDEvent
#if 0
{
  CFRuntimeBase base;	// 0, 4
  AbsoluteTime _timeStamp;	// 8, c
  int x10;	// 10
  int x14;	// 14
  IOOptionBits _options;	// 18
  unsigned _typeMask;	// 1c
  CFMutableArrayRef _children;	// 20
  struct __IOHIDEvent* _parent;	// 24

  size_t recordSize;	// 28
  void record[];
}
#endif
* IOHIDEventRef;


CFTypeRef _IOHIDServiceGetClient(IOHIDServiceRef service);
CFTypeID IOHIDServiceGetTypeID(void);
CFTypeID IOHIDEventGetTypeID(void);
IOHIDEventType IOHIDEventGetType(IOHIDEventRef event);
IOHIDFloat IOHIDEventGetFloatValue(IOHIDEventRef event, IOHIDEventField field);
uint32_t IOHIDEventGetEventFlags(IOHIDEventRef event);
IOHIDEventRef IOHIDEventGetParent(IOHIDEventRef event);
CFArrayRef IOHIDEventGetChildren(IOHIDEventRef event);
int IOHIDEventGetIntegerValue(IOHIDEventRef event, IOHIDEventField field);



typedef struct __IOHIDEventQueue
#if 0
{
  CFRuntimeBase base;	// 0, 4
  IODataQueueMemory* queue;	// 8
  size_t queueSize;	// c
  int notificationPortType;	// 10, 0 -> associate to hidSystem, 1 -> associate to data queue.
  uint32_t token;	// 14
  int topBitOfToken;	// 18, = token >> 31
}
#endif
* IOHIDEventQueueRef;

typedef struct __IOHIDEventSystemClient
#if 0
{
  void* x00;
  CFMachPortRef serverPort;	// 4
  CFRunLoopSourceRef serverSource;	// 8
  IOHIDEventSystemClientEventCallback callback;	// c
  void* target;	// 10
  void* refcon;	// 14
  CFMachPortRef queuePort;	// 18
  CFRunLoopSourceRef queueSource;	// 1c
  CFRunLoopSourceRef source2;	// 24
  CFRunLoopTimerRef timer;	// 28
  IOHIDEventQueueRef queue;	// 2c
  CFRunLoopRef runloop;	// 34
  CFStringRef mode;	// 38
}
#endif
* IOHIDEventSystemClientRef;
typedef void(*IOHIDEventSystemClientEventCallback)(void* target, void* refcon, IOHIDEventQueueRef queue, IOHIDEventRef event);


IOHIDEventSystemClientRef IOHIDEventSystemClientCreate(CFAllocatorRef allocator);

void IOHIDEventSystemClientRegisterEventCallback(IOHIDEventSystemClientRef client, IOHIDEventSystemClientEventCallback callback, void* target, void* refcon);
void IOHIDEventSystemClientUnregisterEventCallback(IOHIDEventSystemClientRef client);

void IOHIDEventSystemClientUnscheduleWithRunLoop(IOHIDEventSystemClientRef client, CFRunLoopRef runloop, CFStringRef mode);
void IOHIDEventSystemClientScheduleWithRunLoop(IOHIDEventSystemClientRef client, CFRunLoopRef runloop, CFStringRef mode);

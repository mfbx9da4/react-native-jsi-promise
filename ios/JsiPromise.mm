#import "JsiPromise.h"
#import <React/RCTBridge+Private.h>
#import <React/RCTUtils.h>
#import <jsi/jsi.h>
#import "react-native-jsi-promise.h"
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

using namespace facebook;

@implementation JsiPromise

@synthesize bridge = _bridge;
@synthesize methodQueue = _methodQueue;

RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup {

    return YES;
}

- (void)setBridge:(RCTBridge *)bridge {
    _bridge = bridge;
    _setBridgeOnMainQueue = RCTIsMainQueue();
    [self installLibrary];
}

- (void)installLibrary {

    RCTCxxBridge *cxxBridge = (RCTCxxBridge *)self.bridge;
    install(*(facebook::jsi::Runtime *)cxxBridge.runtime, self);
}

static void install(jsi::Runtime &jsiRuntime, JsiPromise *cryptoPp) {

    auto myqueue = dispatch_queue_create("myqueue", DISPATCH_QUEUE_CONCURRENT);

    auto foo = jsi::Function::createFromHostFunction(
        jsiRuntime,
        jsi::PropNameID::forAscii(jsiRuntime, "foo"),
        3,
        [cryptoPp, myqueue](jsi::Runtime& runtime, const jsi::Value& thisValue, const jsi::Value* arguments, size_t count) -> jsi::Value {

            CFTimeInterval startTime = CACurrentMediaTime();

            auto promiseConstructor = jsi::Function::createFromHostFunction(
                runtime,
                jsi::PropNameID::forAscii(runtime, "promiseConstructor"),
                2,
                [cryptoPp, startTime, myqueue](jsi::Runtime& runtime, const jsi::Value& thisValue, const jsi::Value* arguments, size_t count) -> jsi::Value {
                    auto resolverValue = std::make_shared<jsi::Value>((arguments[0].asObject(runtime)));

                    NSLog(@"start");
                    dispatch_async(myqueue, ^(void){
                        jsi::Value decryptedJsValue = jsi::Value(runtime, jsi::String::createFromUtf8(runtime, "asdf"));
                        resolverValue->asObject(runtime).asFunction(runtime).call(runtime, decryptedJsValue);
                        NSLog(@"took in seconds %f", CACurrentMediaTime() - startTime);
                    });
                    return jsi::Value::undefined();
                }
            );

            auto newPromise = runtime.global().getProperty(runtime, "Promise");
            auto promise = newPromise
                .asObject(runtime)
                .asFunction(runtime)
                .callAsConstructor(runtime, promiseConstructor);

            return promise;
        }
    );
    jsiRuntime.global().setProperty(jsiRuntime, "foo", std::move(foo));
}


@end

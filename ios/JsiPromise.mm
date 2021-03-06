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

    auto promiseResolver = jsi::Function::createFromHostFunction(
        jsiRuntime,
        jsi::PropNameID::forAscii(jsiRuntime, "promiseResolver"),
        3,
        [cryptoPp, myqueue](jsi::Runtime& runtime, const jsi::Value& thisValue, const jsi::Value* arguments, size_t count) -> jsi::Value {

            CFTimeInterval startTime = CACurrentMediaTime();

            std::shared_ptr<jsi::Value> resolverValue;

            auto promiseConstructor = jsi::Function::createFromHostFunction(
                runtime,
                jsi::PropNameID::forAscii(runtime, "promiseConstructor"),
                2,
                [&resolverValue, cryptoPp, startTime, myqueue](jsi::Runtime& runtime, const jsi::Value& thisValue, const jsi::Value* arguments, size_t count) -> jsi::Value {
                    resolverValue = std::make_shared<jsi::Value>(arguments[0].asObject(runtime));
                    return jsi::Value::undefined();
                }
            );

            auto newPromise = runtime.global().getProperty(runtime, "Promise");
            auto promise = newPromise
                .asObject(runtime)
                .asFunction(runtime)
                .callAsConstructor(runtime, promiseConstructor);

            dispatch_async(myqueue, ^(void){
                jsi::Value decryptedJsValue = jsi::Value(runtime, jsi::String::createFromUtf8(runtime, "asdf"));
                resolverValue->asObject(runtime).asFunction(runtime).call(runtime, decryptedJsValue);
                NSLog(@"took in seconds %f", CACurrentMediaTime() - startTime);
            });

            return promise;
        }
    );
    jsiRuntime.global().setProperty(jsiRuntime, "promiseResolver", std::move(promiseResolver));

    auto pointerToPromiseResolver = jsi::Function::createFromHostFunction(
        jsiRuntime,
        jsi::PropNameID::forAscii(jsiRuntime, "pointerToPromiseResolver"),
        3,
        [cryptoPp, myqueue](jsi::Runtime& runtime, const jsi::Value& thisValue, const jsi::Value* arguments, size_t count) -> jsi::Value {

            CFTimeInterval startTime = CACurrentMediaTime();

            std::shared_ptr<jsi::Value> resolverValue;

            auto promiseConstructor = jsi::Function::createFromHostFunction(
                runtime,
                jsi::PropNameID::forAscii(runtime, "promiseConstructor"),
                2,
                [&resolverValue, cryptoPp, startTime, myqueue](jsi::Runtime& runtime, const jsi::Value& thisValue, const jsi::Value* arguments, size_t count) -> jsi::Value {
                    resolverValue = std::make_shared<jsi::Value>(arguments[0].asObject(runtime));
                    return jsi::Value::undefined();
                }
            );

            auto newPromise = runtime.global().getProperty(runtime, "Promise");
            auto promise = newPromise
                .asObject(runtime)
                .asFunction(runtime)
                .callAsConstructor(runtime, promiseConstructor);

            dispatch_async(myqueue, ^(void){
                jsi::Value decryptedJsValue = jsi::Value(runtime, jsi::String::createFromUtf8(runtime, "asdf"));
                resolverValue->asObject(runtime).asFunction(runtime).call(runtime, decryptedJsValue);
                NSLog(@"took in seconds %f", CACurrentMediaTime() - startTime);
            });

            return promise;
        }
    );
    jsiRuntime.global().setProperty(jsiRuntime, "pointerToPromiseResolver", std::move(pointerToPromiseResolver));

    auto pointerToReturnedValue = jsi::Function::createFromHostFunction(
        jsiRuntime,
        jsi::PropNameID::forAscii(jsiRuntime, "pointerToReturnedValue"),
        1,
        [cryptoPp, myqueue](jsi::Runtime& runtime, const jsi::Value& thisValue, const jsi::Value* arguments, size_t count) -> jsi::Value {

            auto myObj = jsi::Object(runtime);
            jsi::Value obj = jsi::Value(runtime, myObj);
            auto myObjRef = std::make_shared<jsi::Value>(obj.asObject(runtime));


            dispatch_async(myqueue, ^(void){
                auto myVal = jsi::Value(runtime, jsi::String::createFromUtf8(runtime, std::to_string(std::rand())));
                myObjRef->asObject(runtime).setProperty(runtime, "result", myVal);
            });

            return obj;
        }
    );
    jsiRuntime.global().setProperty(jsiRuntime, "pointerToReturnedValue", std::move(pointerToReturnedValue));


    auto foo = jsi::Function::createFromHostFunction(
        jsiRuntime,
        jsi::PropNameID::forAscii(jsiRuntime, "foo"),
        1,
        [cryptoPp, myqueue](jsi::Runtime& runtime, const jsi::Value& thisValue, const jsi::Value* arguments, size_t count) -> jsi::Value {

            auto userCallbackRef = std::make_shared<jsi::Object>(arguments[0].getObject(runtime));

            dispatch_async(myqueue, ^(void){
                auto val = jsi::String::createFromUtf8(runtime, std::to_string(std::rand()));
                auto error = jsi::Value::undefined();
                userCallbackRef->asFunction(runtime).call(runtime, error, val);
            });

            return jsi::Value::undefined();
        }
    );
    jsiRuntime.global().setProperty(jsiRuntime, "foo", std::move(foo));
}


@end

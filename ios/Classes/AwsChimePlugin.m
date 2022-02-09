#import "AwsChimePlugin.h"
#if __has_include(<aws_chime_plugin/aws_chime_plugin-Swift.h>)
#import <aws_chime_plugin/aws_chime_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "aws_chime_plugin-Swift.h"
#endif

@implementation AwsChimePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAwsChimePlugin registerWithRegistrar:registrar];
}
@end

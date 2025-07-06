//! Build logic for Ghostshell. A single "build.zig" file became far too complex
//! and spaghetti, so this package extracts the build logic into smaller,
//! more manageable pieces.

pub const gtk = @import("gtk.zig");
pub const Config = @import("Config.zig");
pub const GitVersion = @import("GitVersion.zig");

// Artifacts
pub const GhostshellBench = @import("GhostshellBench.zig");
pub const GhostshellDist = @import("GhostshellDist.zig");
pub const GhostshellDocs = @import("GhostshellDocs.zig");
pub const GhostshellExe = @import("GhostshellExe.zig");
pub const GhosttyFrameData = @import("GhosttyFrameData.zig");
pub const GhostshellLib = @import("GhostshellLib.zig");
pub const GhostshellResources = @import("GhostshellResources.zig");
pub const GhostshellI18n = @import("GhostshellI18n.zig");
pub const GhosttyXcodebuild = @import("GhosttyXcodebuild.zig");
pub const GhosttyXCFramework = @import("GhosttyXCFramework.zig");
pub const GhostshellWebdata = @import("GhostshellWebdata.zig");
pub const HelpStrings = @import("HelpStrings.zig");
pub const SharedDeps = @import("SharedDeps.zig");
pub const UnicodeTables = @import("UnicodeTables.zig");

// Steps
pub const LibtoolStep = @import("LibtoolStep.zig");
pub const LipoStep = @import("LipoStep.zig");
pub const MetallibStep = @import("MetallibStep.zig");
pub const XCFrameworkStep = @import("XCFrameworkStep.zig");

// Shell completions
pub const fish_completions = @import("fish_completions.zig").completions;
pub const zsh_completions = @import("zsh_completions.zig").completions;
pub const bash_completions = @import("bash_completions.zig").completions;

// Helpers
pub const requireZig = @import("zig.zig").requireZig;

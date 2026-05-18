#!/usr/bin/env python3
"""
Fix mojibake emoji in Dart source files.
Mojibake occurs when UTF-8 emoji bytes were saved as Latin-1/Windows-1252 encoded text.
Each mojibake string was produced by misreading the UTF-8 bytes of the emoji as Latin-1.
"""
import os
import glob

# Map: mojibake string (as it appears in the file) → correct emoji
# Produced by encoding each emoji's UTF-8 bytes as Latin-1 characters
FIXES = {
    # Emoji from 4-byte UTF-8 sequences (U+1F000 range)
    "\xf0\x9f\x86\x98": "\U0001F198",  # 🆘 SOS  (F0 9F 86 98)
    "\xf0\x9f\x96\x83": "\U0001F583",  # 📃 (check if correct)
    "\xf0\x9f\x96\x8c": "\U0001F56C",  # check
    "\xf0\x9f\x96\xa5": "\U0001F5A5",  # check
    "\xf0\x9f\xa5\xac": "\U0001F96C",  # 🥬 leafy green
    "\xf0\x9f\x8c\xb1": "\U0001F331",  # 🌱 seedling
    "\xf0\x9f\x8c\xbe": "\U0001F33E",  # 🌾 sheaf of rice
    "\xf0\x9f\x95\x8c": "\U0001F54C",  # 🕌 mosque (Halal)
    "\xf0\x9f\x8c\xbf": "\U0001F33F",  # 🌿 herb (Organic)
    "\xf0\x9f\xa5\x87": "\U0001F947",  # 🥇 gold medal
    "\xf0\x9f\x9a\x97": "\U0001F697",  # 🚗 car
    "\xf0\x9f\x93\x8b": "\U0001F4CB",  # 📋 clipboard
    "\xf0\x9f\x93\xb8": "\U0001F4F8",  # 📸 camera with flash
    "\xf0\x9f\x8e\x89": "\U0001F389",  # 🎉 party popper
    "\xf0\x9f\xa4\x96": "\U0001F916",  # 🤖 robot
    "\xf0\x9f\x9b\xa1": "\U0001F6E1",  # 🛡 shield (without variation selector)
    "\xf0\x9f\x9b\xa1\xef\xb8\x8f": "\U0001F6E1\uFE0F",  # 🛡️ shield + VS16
    "\xf0\x9f\x94\x90": "\U0001F510",  # 🔐 locked with key
    "\xf0\x9f\x94\x91": "\U0001F511",  # 🔑 key
    "\xf0\x9f\x8f\xa0": "\U0001F3E0",  # 🏠 house (lifestyle)
    "\xf0\x9f\x92\xbc": "\U0001F4BC",  # 💼 briefcase (career)
    "\xf0\x9f\x92\xb0": "\U0001F4B0",  # 💰 money bag (financial)
    "\xf0\x9f\x8f\xa5": "\U0001F3E5",  # 🏥 hospital (health)
    "\xf0\x9f\x94\x84": "\U0001F504",  # 🔄 counterclockwise arrows
    "\xf0\x9f\x9f\xa1": "\U0001F7E1",  # 🟡 yellow circle
    "\xf0\x9f\x94\xb4": "\U0001F534",  # 🔴 red circle
    "\xf0\x9f\x8e\x96": "\U0001F396",  # 🎖 military medal
    "\xf0\x9f\x93\xa3": "\U0001F4E3",  # 📣 megaphone
    "\xf0\x9f\x91\xa8\xe2\x80\x8d\xf0\x9f\x91\xa9\xe2\x80\x8d\xf0\x9f\x91\xa7\xe2\x80\x8d\xf0\x9f\x91\xa6": "👨‍👩‍👧‍👦",  # family

    # 3-byte UTF-8 sequences (U+0800-U+FFFF range)
    "\xe2\x9c\x93": "\u2713",   # ✓ check mark
    "\xe2\x9c\x85": "\u2705",   # ✅ white heavy check mark
    "\xe2\x9d\x8c": "\u274C",   # ❌ cross mark
    "\xe2\x86\xa9": "\u21A9",   # ↩ left arrow with hook
    "\xe2\x86\xa9\xef\xb8\x8f": "\u21A9\uFE0F",  # ↩️ with variation selector
    "\xe2\x9c\xa1": "\u2721",   # ✡ Star of David
    "\xe2\x9a\x96\xef\xb8\x8f": "\u2696\uFE0F",  # ⚖️ scales
    "\xe2\x9a\x96": "\u2696",   # ⚖ scales
}


def fix_file(filepath):
    """Read file as bytes, decode as Latin-1 to get the original bytes, fix mojibake."""
    with open(filepath, 'rb') as f:
        raw_bytes = f.read()

    # Decode as UTF-8 to get the current content
    try:
        content = raw_bytes.decode('utf-8')
    except UnicodeDecodeError:
        print(f"  SKIP (not valid UTF-8): {filepath}")
        return False

    original = content

    # Apply each fix: the mojibake sequence → correct character
    # The mojibake strings are \xNN byte sequences — these are the Latin-1 codepoints
    # that correspond to the UTF-8 bytes of the emoji. In the actual Python string,
    # these \xNN escapes are the Unicode codepoints U+00NN, which is what Latin-1 maps them to.
    for mojibake_bytes, correct in FIXES.items():
        if mojibake_bytes in content:
            content = content.replace(mojibake_bytes, correct)

    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    return False


def main():
    base = r"C:\Users\Wisdom Amaniampong\Desktop\Code\thedep\thepg\lib"
    pattern = os.path.join(base, "**", "*.dart")
    files = glob.glob(pattern, recursive=True)
    changed = 0
    for filepath in files:
        if fix_file(filepath):
            changed += 1
            print(f"Fixed: {os.path.basename(filepath)}")
    print(f"\nTotal files fixed: {changed}")


if __name__ == "__main__":
    main()

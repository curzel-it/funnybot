import pdb

for id in []:  # Do not overwrite existing ones!
    f = open(f"example{id}.md")
    content = f.readlines()
    f.close()

    def is_good(l):
        if ": at" in l:
            return False
        if ": turn" in l:
            return False
        if "camera: " in l:
            return False
        if ": set x" in l:
            return False
        if ": set y" in l:
            return False
        if ": offset x" in l:
            return False
        if ": offset y" in l:
            return False
        return True
        # and ': turn' not in l and 'camera: ' not in l

    content = [l.strip() for l in content if is_good(l)]
    f = open(f"example{id}_auto.md", "w")
    f.write("\n".join(content))
    f.close()

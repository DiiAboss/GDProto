import os

def count_lines_of_code(directory='.', extensions=None):
    """
    Count lines of code in all files in a directory.
    
    Args:
        directory: Starting directory (default is current directory)
        extensions: List of file extensions to include (e.g., ['.py', '.js', '.cpp'])
                   If None, counts all text files
    """
    total_lines = 0
    file_count = 0
    
    for root, dirs, files in os.walk(directory):
        for file in files:
            # Skip if extensions specified and file doesn't match
            if extensions and not any(file.endswith(ext) for ext in extensions):
                continue
                
            file_path = os.path.join(root, file)
            try:
                with open(file_path, 'r', errors='ignore') as f:
                    lines = sum(1 for _ in f)
                    total_lines += lines
                    file_count += 1
                    print(f"{file_path}: {lines} lines")
            except Exception as e:
                print(f"Skipped {file_path}: {e}")
    
    print(f"\nTotal files: {file_count}")
    print(f"Total lines of code: {total_lines}")

if __name__ == "__main__":
    # Count all Python files
    # count_lines_of_code('.', ['.py'])
    
    # Or count all files
    count_lines_of_code('.')
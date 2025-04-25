# This script will batch move multiple files in subdirectories and move them into a Destination directory
# Used for moving multiple files into one folder


$OriginalDirectory = "C:\Users\XXXXX" # Where the files are
$subDirectory = Get-ChildItem $OriginalDirectory # Get every folder in $OriginalDirectory
$destinationDirectory = "C:\Users\XXXXX" # Where the files are going


# METHOD 1
# Simple extraction per folder if there is only one folder with items in it
foreach ($folder in $subDirectory) {
    Write-Color -Text "Moving file ", "$($folder)", " and placing in destination folder ", 
    "$($destinationDirectory)" -Color Green, White, Green, White
    $files = Get-ChildItem $folder
    foreach ($file in $files) {
        Move-Item $file -Destination $destinationDirectory
    }
}


# METHOD 2
# Extraction if there are multiple directories

$extensions = "*.epub", "*.mobi", "*.azw", "*.azw3", "*.azw4", "*.kfx", "*.pdf", "*.txt", "*.rtf", "*.html", "*.cbz", "*.cbr", "*.doc", "*.docx", "*.epub3", "*.fb2", "*.lit", "*.pdb", "*.chm", "*.djvu", "*.xhtml", "*.cbt"
$Files = Get-ChildItem -Path "C:\Users\XXXXX" -Recurse -Include $extensions # Get files that end in specific extensions listed in line 25

foreach ($file in $Files){
    Write-Color -Text "Moving", " $($file.Name)" -Color Cyan, White
    try {
        # Attempt to move the file
        Move-Item -Path $file.FullName -Destination $destinationDirectory -ErrorAction Stop
    }
    catch {
        # If an error occurs, print the name of file it errored on
        Write-Host "Failed to move '$($file.Name)': $_" -ForegroundColor Red
    }
} 
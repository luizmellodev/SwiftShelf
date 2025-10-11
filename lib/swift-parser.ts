/**
 * Parses Swift code and splits it into sections based on MARK comments
 */

export interface CodeSection {
  name: string
  code: string
  startLine: number
  endLine: number
}

/**
 * Extracts sections from Swift code based on MARK comments and code structure
 * Example: // MARK: - Snackbar Type, or detects struct/enum/class/extension automatically
 */
export function parseSwiftCode(code: string): CodeSection[] {
  const lines = code.split('\n')
  const sections: CodeSection[] = []
  
  // Find all MARK comments
  const markIndices: Array<{ index: number; name: string; type: 'mark' }> = []
  
  lines.forEach((line, index) => {
    const trimmed = line.trim()
    // Match MARK comments: // MARK: - Name or // MARK: Name
    const markMatch = trimmed.match(/^\/\/\s*MARK:\s*-?\s*(.+)/)
    if (markMatch) {
      markIndices.push({
        index,
        name: markMatch[1].trim(),
        type: 'mark'
      })
    }
  })
  
  // If MARK comments found, use them
  if (markIndices.length > 0) {
    markIndices.forEach((mark, i) => {
      const startLine = mark.index
      const endLine = i < markIndices.length - 1 ? markIndices[i + 1].index - 1 : lines.length - 1
      
      const sectionLines = lines.slice(startLine + 1, endLine + 1)
      
      // Remove leading and trailing empty lines
      while (sectionLines.length > 0 && sectionLines[0].trim() === '') {
        sectionLines.shift()
      }
      while (sectionLines.length > 0 && sectionLines[sectionLines.length - 1].trim() === '') {
        sectionLines.pop()
      }
      
      if (sectionLines.length > 0) {
        sections.push({
          name: mark.name,
          code: sectionLines.join('\n'),
          startLine: startLine + 1,
          endLine: endLine
        })
      }
    })
    return sections
  }
  
  // If no MARK comments, try to detect code structure automatically
  const structureIndices: Array<{ index: number; name: string; type: string }> = []
  
  lines.forEach((line, index) => {
    const trimmed = line.trim()
    
    // Match struct
    const structMatch = trimmed.match(/^(?:public\s+|private\s+|internal\s+)?struct\s+(\w+)/)
    if (structMatch) {
      structureIndices.push({ index, name: structMatch[1], type: 'struct' })
      return
    }
    
    // Match enum
    const enumMatch = trimmed.match(/^(?:public\s+|private\s+|internal\s+)?enum\s+(\w+)/)
    if (enumMatch) {
      structureIndices.push({ index, name: enumMatch[1], type: 'enum' })
      return
    }
    
    // Match class
    const classMatch = trimmed.match(/^(?:public\s+|private\s+|internal\s+|@MainActor\s+)*class\s+(\w+)/)
    if (classMatch) {
      structureIndices.push({ index, name: classMatch[1], type: 'class' })
      return
    }
    
    // Match extension
    const extensionMatch = trimmed.match(/^extension\s+(\w+)/)
    if (extensionMatch) {
      structureIndices.push({ index, name: `${extensionMatch[1]} Extension`, type: 'extension' })
      return
    }
    
    // Match #Preview
    const previewMatch = trimmed.match(/^#Preview/)
    if (previewMatch) {
      structureIndices.push({ index, name: 'Preview', type: 'preview' })
      return
    }
  })
  
  // If structure elements found, create sections
  if (structureIndices.length > 0) {
    structureIndices.forEach((structure, i) => {
      const startLine = structure.index
      const endLine = i < structureIndices.length - 1 ? structureIndices[i + 1].index - 1 : lines.length - 1
      
      const sectionLines = lines.slice(startLine, endLine + 1)
      
      // Remove trailing empty lines
      while (sectionLines.length > 0 && sectionLines[sectionLines.length - 1].trim() === '') {
        sectionLines.pop()
      }
      
      if (sectionLines.length > 0) {
        sections.push({
          name: structure.name,
          code: sectionLines.join('\n'),
          startLine: startLine,
          endLine: endLine
        })
      }
    })
    return sections
  }
  
  // If nothing found, return entire code as one section
  return [{
    name: 'Code',
    code: code,
    startLine: 0,
    endLine: lines.length - 1
  }]
}

/**
 * Generates a filename suggestion based on the section name
 */
export function getFilenameFromSection(sectionName: string, index: number): string {
  // Common patterns to extract clean filenames
  const cleanName = sectionName
    .replace(/\s+/g, '')
    .replace(/[^a-zA-Z0-9]/g, '')
  
  // Map common section names to appropriate filenames
  const nameMap: Record<string, string> = {
    'SnackbarType': 'SnackbarType.swift',
    'SnackbarPosition': 'SnackbarPosition.swift',
    'SnackbarConfiguration': 'SnackbarConfiguration.swift',
    'SnackbarView': 'SnackbarView.swift',
    'SnackbarModifier': 'SnackbarModifier.swift',
    'SnackbarManager': 'SnackbarManager.swift',
    'ViewExtension': 'View+Extension.swift',
    'Preview': 'Preview.swift'
  }
  
  // Try to find a match in the name map
  for (const [key, value] of Object.entries(nameMap)) {
    if (cleanName.toLowerCase().includes(key.toLowerCase())) {
      return value
    }
  }
  
  // Default to section name with .swift extension
  return `${cleanName || `Section${index + 1}`}.swift`
}

/**
 * Checks if code should be collapsible (longer than threshold)
 */
export function shouldCollapseCode(code: string, lineThreshold: number = 30): boolean {
  const lines = code.split('\n')
  return lines.length > lineThreshold
}

/**
 * Gets a preview of the code (first N lines)
 */
export function getCodePreview(code: string, previewLines: number = 20): string {
  const lines = code.split('\n')
  if (lines.length <= previewLines) {
    return code
  }
  return lines.slice(0, previewLines).join('\n') + '\n\n// ... (click "Show full code" to see more)'
}


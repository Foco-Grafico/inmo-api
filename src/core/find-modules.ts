import path from 'path'
import fs from 'fs'

export const findAllModulesPaths = (dir: string, modules: string[] = []) => {
  const files = fs.readdirSync(dir)
  files.forEach(file => {
    const filePath = path.join(dir, file
    )
    const stat = fs.statSync(filePath)
    if (stat.isDirectory()) {
      findAllModulesPaths(filePath, modules)
    } else {
      if (file.endsWith('router.ts')) {
        modules.push(filePath)
      }
    }
  })
  return modules
}

export const importAllModules = async (dirModules: string[]) => {
  return await Promise.all(dirModules.map(async (path) => {
    const module = await import(path)
    return module.default
  }))
}

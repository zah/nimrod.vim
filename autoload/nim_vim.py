from sys import version_info
from os import name
import threading, subprocess, signal, os, platform, getpass, re, copy

if version_info[0] == 3:
    import queue as Queue
else:
    import Queue

try:
  import vim
except ImportError:
  class Vim:
    def command(self, x):
      print("Executing vim command: " + x)
  
  vim = Vim()

class NimThread(threading.Thread):
  def __init__(self, cmd, project_path):
    super(NimThread, self).__init__()
    self.tasks = Queue.Queue()
    self.responses = Queue.Queue()
    if name == 'nt':
        si = subprocess.STARTUPINFO()
        si.dwFlags |= subprocess.STARTF_USESHOWWINDOW
        si.wShowWindow = subprocess.SW_HIDE
    else:
        si = None
    cmd.append(project_path)
    self.nim = subprocess.Popen(
       cmd,
       cwd = os.path.dirname(project_path),
       stdin = subprocess.PIPE,
       stdout = subprocess.PIPE,
       stderr = subprocess.STDOUT,
       universal_newlines = True,
       startupinfo = si,
       bufsize = 1)
 
  def postNimCmd(self, msg, async = True):
    self.tasks.put((msg, async))
    if not async:
      return self.responses.get()

  def run(self):
    while True:
      (msg, async) = self.tasks.get()

      if msg == "quit":
        self.nim.terminate()
        break

      self.nim.stdin.write(msg + "\n")
      self.nim.stdin.flush()
      result = ""
      
      while True:
        line = self.nim.stdout.readline()
        result += line
        if re.match('^(?:\n|>\s*)$', line) is not None:
          if not async:
            self.responses.put(result)
          else:
            self.asyncOpComplete(msg, result)
          break
        

def nimVimEscape(expr):
  return expr.replace("\\", "\\\\").replace('"', "\\\"").replace("\n", "\\n")

class NimVimThread(NimThread):
  def asyncOpComplete(self, msg, result):
    cmd = "/usr/local/bin/mvim --remote-expr 'NimAsyncCmdComplete(1, \"" + nimVimEscape(result) + "\")'"
    os.system (cmd)

NimProjects = {}

def nimStartService(cmd, project):
  target = NimVimThread(cmd, project)
  NimProjects[project] = target
  target.start()
  return target

def nimTerminateService(project):
  if NimProjects.has_key(project):
    NimProjects[project].postNimCmd("quit")
    del NimProjects[project]

def nimRestartService(project):
  nimTerminateService(project)
  server = copy.copy(vim.vars['nim_server_cmd'][0:])
  if version_info[0] == 3:
    for i in range(len(server)):
        server[i] = server[i].decode()
  nimStartService(server, project)

def nimExecCmd(project, cmd, async = True):
  target = None
  if NimProjects.has_key(project):
    target = NimProjects[project]
  else:
    server = copy.copy(vim.vars['nim_server_cmd'][0:])
    if version_info[0] == 3:
      for i in range(len(server)):
          server[i] = server[i].decode()
    target = nimStartService(server, project)
  
  result = target.postNimCmd(cmd, async)
  
  if not async:
    vim.command('let l:py_res = "' + nimVimEscape(result) + '"')

def nimTerminateAll():
  for thread in NimProjects.values():
    thread.postNimCmd("quit")
    

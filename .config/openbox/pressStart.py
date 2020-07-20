from pynput.keyboard import Key, Controller

def main():
  keyboard = Controller()
  keyboard.press(Key.cmd)
  keyboard.release(Key.cmd)

if __name__ == "__main__":
  main()

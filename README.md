## Cowboy Bebop GRUB Theme

A Cowboy Bebop-inspired GRUB bootloader theme with Edward's terminal aesthetic — green CRT scanlines, retro monospace font, and iconic quotes from the series.

> Fork of [Fallout GRUB Theme](https://github.com/shvchk/fallout-grub-theme) by [shvchk](https://github.com/shvchk)

![](demo.png)

### Features

- 🖥️ Edward-style green CRT terminal aesthetic
- 🎵 Iconic Cowboy Bebop quotes ("YOU'RE GONNA CARRY THAT WEIGHT.")
- 🌍 17 languages supported
- 📐 Responsive layout for multiple resolutions

**Supported languages:** Chinese (simplified), Chinese (traditional), English, French, German, Hungarian, Italian, Korean, Latvian, Norwegian, Polish, Portuguese, Russian, Rusyn, Spanish, Turkish, Ukrainian

---

### Installation / update

- **Secure way:**
  - Download install script:

    ```sh
    wget -P /tmp https://github.com/YukaC/cowboy-bebop-grub-theme/raw/master/install.sh
    ```

  - Review it at `/tmp/install.sh`

  - Run it:

    ```sh
    bash /tmp/install.sh
    ```

- **Easier, less secure way** — just download and run install script:

  ```sh
  wget -O - https://github.com/YukaC/cowboy-bebop-grub-theme/raw/master/install.sh | bash
  ```

<br>

You can use `--lang` option to select language and disable interactive language selection, e.g.:

```sh
bash /tmp/install.sh --lang German
```

or

```sh
wget -O- https://github.com/YukaC/cowboy-bebop-grub-theme/raw/master/install.sh | bash -s -- --lang Korean
```

Full list of languages see in `INSTALLER_LANGS` variable in [install.sh](install.sh)

---

### Credits

- Original theme by [shvchk](https://github.com/shvchk/fallout-grub-theme)
- Cowboy Bebop adaptation by [YukaC](https://github.com/YukaC)
- Font: [Fixedsys Excelsior](http://www.fixedsysexcelsior.com/)

---

_See you space cowboy..._

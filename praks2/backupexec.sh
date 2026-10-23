#!/bin/bash

# --- KONFIGURATSIOON ---
SRC_DIR="$HOME/Linux_skriptimine/praks2/src"
BCP_DIR="$HOME/Linux_skriptimine/praks2/backup"
LOG_DIR="$HOME/Linux_skriptimine/praks2/logs"
LOG_FILE="$LOG_DIR/backup.log"
IGNORE_FILE="$SRC_DIR/.backupignore"
KEEP_COUNT=3
COMPRESSOR="zstd" # Valikud: zstd, gzip, xz

# Loome vajalikud kataloogid
mkdir -p "$BCP_DIR" "$LOG_DIR"

# Ajutise kataloogi seadistamine (Clean-up trap)
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# Logimise funktsioon
log_msg() {
    echo "[ $(date '+%F %T') ] $1" | tee -a "$LOG_FILE"
}

log_msg "--- BACKUP ALUSTATUD ---"

# 1. Kontrollime, kas algkataloog on olemas
if [ ! -d "$SRC_DIR" ]; then
    log_msg "VIGA: Algkataloogi $SRC_DIR ei leitud!"
    exit 1
fi

# 2. Vaba ruumi kontroll (Baitides)
NEEDED_SPACE=$(du -sb "$SRC_DIR" | awk '{print $1}')
FREE_SPACE=$(df -B1 "$BCP_DIR" | awk 'NR==2 {print $4}')

if [ "$FREE_SPACE" -lt "$NEEDED_SPACE" ]; then
    log_msg "VIGA: Ketta ruumi pole piisavalt! Vajalik: $NEEDED_SPACE, Vaba: $FREE_SPACE"
    exit 1
fi

# 3. Kompressori määratlus
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
case "$COMPRESSOR" in
    zstd)
        EXT="tar.zst"
        TAR_OPT=(-I 'zstd -19 -T0')
        ;;
    gzip)
        EXT="tar.gz"
        TAR_OPT=(-z)
        ;;
    xz)
        EXT="tar.xz"
        TAR_OPT=(-J)
        ;;
    *)
        log_msg "VIGA: Tundmatu kompressor $COMPRESSOR!"
        exit 1
        ;;
esac

ARCHIVE_NAME="src_${TIMESTAMP}.${EXT}"
ARCHIVE_PATH="$BCP_DIR/$ARCHIVE_NAME"

# 4. .backupignore kontroll
EXCLUDE_OPT=()
if [ -f "$IGNORE_FILE" ]; then
    EXCLUDE_OPT=(--exclude-from="$IGNORE_FILE")
    log_msg "Kasutan välistuste faili: $IGNORE_FILE"
fi

# 5. Arhiivi loomine
log_msg "Loon arhiivi: $ARCHIVE_NAME ($COMPRESSOR)..."
tar "${TAR_OPT[@]}" "${EXCLUDE_OPT[@]}" -cf "$ARCHIVE_PATH" -C "$(dirname "$SRC_DIR")" "$(basename "$SRC_DIR")"

if [ $? -ne 0 ]; then
    log_msg "VIGA: Arhiivi loomine ebaõnnestus!"
    exit 1
fi

# 6. Arhiivi suuruse kuvamine
ARCHIVE_SIZE=$(du -h "$ARCHIVE_PATH" | awk '{print $1}')
log_msg "Arhiivi suurus: $ARCHIVE_SIZE"

# 7. Arhiivi terviklikkuse kontroll
log_msg "Kontrollin arhiivi sisu..."
if [ "$COMPRESSOR" = "zstd" ]; then
    tar -I 'zstd -d' -tf "$ARCHIVE_PATH" > /dev/null 2>&1
else
    tar -tf "$ARCHIVE_PATH" > /dev/null 2>&1
fi

if [ $? -eq 0 ]; then
    log_msg "Arhiivi kontroll OK!"
else
    log_msg "VIGA: Arhiiv on vigane või kahjustatud!"
    exit 1
fi

# 8. SHA-256 kontrollsumma arvutamine
log_msg "Arvutan SHA-256 kontrollsumma..."
sha256sum "$ARCHIVE_PATH" > "${ARCHIVE_PATH}.sha256"

# 9. Ainult viimaste (KEEP_COUNT) koopiate hoidmine
log_msg "Puhastan vanu arhiive (alles jääb $KEEP_COUNT viimast)..."
cd "$BCP_DIR" || exit 1
ls -1t src_*.tar.* 2>/dev/null | tail -n +$((KEEP_COUNT + 1)) | while read -r old_file; do
    rm -f "$old_file" "${old_file}.sha256"
    log_msg "Kustutatud vana arhiiv: $old_file"
done

log_msg "--- BACKUP LÕPETATUD EDUKALT ---"

#!/bin/bash

echo "🔍 Проверка кодировки файлов..."

for file in services/*/index.html; do
    echo "📄 $file:"
    file -i "$file"
    echo "---"
done

echo "✅ Проверка завершена"

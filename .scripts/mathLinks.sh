#!/bin/bash

YELLOW='\033[0;33m'
PURPLE='\033[0;35m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

cd ~/Dropbox/MathWiki/Notes

Math()
{
    local r=$(echo "$1" | sed -E 's/\bR\b/\$\\R\$/g')                                         # Real numbers
    local r=$(echo "$r" | sed -E 's/\bN\b/\$\\N\$/g')                                         # Natural numbers
    local r=$(echo "$r" | sed -E 's/\bR2\b/\$\\R\^2\$/g')                                     # Real numbers squared
    local r=$(echo "$r" | sed -E 's/\bN2\b/\$\\N\^2\$/g')                                     # Natural numbers squared
    local r=$(echo "$r" | sed -E 's/\bequals\b/\$=\$/g')                                      # Equals
    local r=$(echo "$r" | sed -E 's/\bimplies\b/\$\\Rightarrow\$/g')                          # Implies
    local r=$(echo "$r" | sed -E 's/\biff\b/\$\\Leftrightarrow\$/g')                          # Equivalence
    local r=$(echo "$r" | sed -E 's/\bON\b/\$\\textrm\{ON\}\$/g')                             # Class of ordinals
    local r=$(echo "$r" | sed -E 's/\bK\b/\$K\$/g')                                           # K topology
    local r=$(echo "$r" | sed -E 's/\ slash\ /\$\\slash\$/g')                                 # Slash
    local r=$(echo "$r" | sed -E 's/\bCategory\sof\sSets\b/\$\\catset\$/gI')                  # Category of Sets
    local r=$(echo "$r" | sed -E 's/\bCategory\sof\sRelations\b/\$\\catrel\$/gI')             # Category of Relations
    local r=$(echo "$r" | sed -E 's/\bCategory\sof\sVector\sSpaces\b/\$\\catvect[K]\$/gI')    # Category of Vector Spaces over K
    local r=$(echo "$r" | sed -E 's/\brepr\sunder\sbasis\b/\$\\Leftrightarrow\^\\textrm\{repr\.\}_\\textrm\{bases\}\$/gI')
        # ...represented by/represents under a choice of basis

    # Prefix Letters
    local r=$(echo "$r" | sed -E 's/\bn-\b/\$n\$-/g')                                         # n
    echo "$r"
}

Format()
{
    local r=$(echo "$1" | sed 's/\\/\\\\/g')                                # Escape \
    local r=$(echo "$r" | sed 's/\ /\\s/g')                                 # Escape <Space>
    local r=$(echo "$r" | sed 's/\[/\\\[/g')                                # Escape [
    local r=$(echo "$r" | sed 's/\]/\\\]/g')                                # Escape ]
    local r=$(echo "$r" | sed 's/(/\\(/g')                                  # Escape (
    local r=$(echo "$r" | sed 's/)/\\)/g')                                  # Escape )
    local r=$(echo "$r" | sed 's/{/\\{/g')                                  # Escape {
    local r=$(echo "$r" | sed 's/}/\\}/g')                                  # Escape }
    local r=$(echo "$r" | sed 's/\$/\\\$/g')                                # Escape $
    local r=$(echo "$r" | sed 's/\^/\\\^/g')                                # Escape ^
    local r=$(echo "$r" | sed 's/|/\\|/g')                                  # Escape |
    local r=$(echo "$r" | sed 's/+/\\+/g')                                  # Escape +
    local r=$(echo "$r" | sed 's/\./\\./g')                                 # Escape .
    echo "$r"
}

while [ ! -z "$1" ]; do
    case "$1" in
        --update|-u)
            printf "\n"
            echo -e "${PURPLE}Updating math links...${NC}"
            allLinks=$(grep -Poh '\[((?!\]\(|\]\]).)*\]\(([^\$^\[^\]]+%20)+[^\$^\[^\]]*(\.md)*\)' * | sort | uniq)

            numberOfLinks=`echo "$allLinks" | wc -l`
            updateInterval=$(bc -l <<< 'scale=1; ('"$numberOfLinks"'/'100')+'0.5'' | sed 's/\..*//g')
            counter=0

            while IFS= read -r link; do
                # Get obsidian link
                obsidian=${link#*](}
                obsidian=${obsidian::-1}
                obsidianLength=$(echo ${#obsidian})

                # Extract current from obsidian
                current=${link::-$obsidianLength}
                current=${current:1}
                current=${current::-3}

                # Extract new from obsidian and compare; replace if different
                new=$(echo "$obsidian" | sed 's/\(.*\).md/\1/' | sed 's/%20/\ /g')
                custom=$(grep "custom_alias: " "$new.md")
                if [[ -z $custom ]]; then
                    new=$(Math "$new")
                    if [ ! "$current" == "$new" ]; then
                        currentTemp=$(echo "$current" | sed -E 's/\\/\\\\/g')
                        new=$(echo "$new" | sed -E 's/\\/\\\\/g')
                        echo -e "${RED}$currentTemp${NC} -> ${GREEN}$new${NC}"
                        read -u 1 -n 1 -p "$(echo -e '\n'"    ${PURPLE}Proceed? [Y/n]${NC} ")" proceed
                        if [ -z "$proceed" ] || [ "$proceed" == "Y" ]; then
                            currentFormatted=$(Format "$current")
                            files=$(grep -l "$obsidian" *)

                            while IFS= read -r file; do
                                sed -Ei 's/'"$currentFormatted"'/'"$new"'/g' "$file"
                                echo "        $file"
                            done <<< "$files"
                        fi
                        printf "\n"
                    fi
                else
                    name=$(echo "$obsidian" | sed 's/%20/\ /g')
                    currentFile=$(grep "custom_alias: " "$name")
                    alias=$(echo "$currentFile" | sed 's/^.*:\ //g')
                    new=$(echo "$alias" | sed 's/.md//g')
                    if [ ! "$current" == "$new" ]; then
                        currentTemp=$(echo "$current" | sed -E 's/\\/\\\\/g')
                        new=$(echo "$new" | sed -E 's/\\/\\\\/g')
                        echo -e "${RED}$currentTemp${NC} -> ${GREEN}$new${NC}"
                        read -u 1 -n 1 -p "$(echo -e '\n'"    ${PURPLE}Proceed? [Y/n]${NC} ")" proceed
                        if [ -z "$proceed" ] || [ "$proceed" == "Y" ]; then
                            currentFormatted=$(Format "$current")
                            files=$(grep -l "$obsidian" *)

                            while IFS= read -r file; do
                                sed -Ei 's/'"$currentFormatted"'/'"$new"'/g' "$file"
                                echo "        $file"
                            done <<< "$files"
                        fi
                        printf "\n"
                    fi
                fi

                if [[ ! -z "$updateInterval" ]]; then
                    counter=$(("$counter" + 1))
                    if [[ $(("$counter"%"$updateInterval")) = 0 ]]; then
                        percentage=$(bc -l <<< 'scale=2; '"$counter"'/'"$numberOfLinks"''*100 | sed 's/\.00$//g')
                        echo -ne "    ${YELLOW}$percentage%${NC}\r"
                    fi
                fi
            done <<< "$allLinks"
            echo -e "    ${PURPLE}DONE${NC}"
            printf "\n"
        ;;
        --new|-n)
            echo -e "${PURPLE}Generating math links...${NC}"
            allFiles=$(grep -l 'alias: auto_aliasing\|custom_alias:' *)
            allDoubleCurrent=$(sed 's/^/\[\[/g' <<< "$allFiles")
            allDoubleCurrent=$(sed 's/$/\]\]/g' <<< "$allDoubleCurrent")
            allDoubleCurrent=$(sed 's/.md//g' <<< "$allDoubleCurrent")

            numberOfDouble=`echo "$allDoubleCurrent" | wc -l`
            updateInterval=$(bc -l <<< 'scale=1; ('"$numberOfDouble"'/'100')+'0.5'' | sed 's/\..*//g')
            counter=0

            while IFS= read -r current; do
                currentFormatted=$(Format "$current")
                if [[ ! -z $(grep -P "$currentFormatted" *) ]]; then
                    currentTemp=$(echo "$current" | sed 's/\[\[//g' | sed 's/\]\]//g' | sed 's/$/.md/g')
                    currentFile=$(grep "custom_alias: " "$currentTemp")
                    if [[ ! -z $currentFile ]]; then
                        alias=$(echo "$currentFile" | sed 's/^.*:\ //g')
                        left=$(echo "["$alias"]" | sed 's/.md//g')
                    else
                        left="["$(Math "$currentTemp" | sed 's/.md//g')"]"
                    fi

                    right=${allDoubleCurrent%%$'\n'*}
                    right=$(echo "$right" | sed 's/\[\[/\(/g' | sed 's/\]\]/.md\)/g' | sed 's/\ /%20/g')

                    new=$left$right
                    new=$(echo "$new" | sed 's/\\/\\\\/g')
                    echo -e "${RED}$current${NC} -> ${GREEN}$new${NC}"
                    read -u 1 -n 1 -p "$(echo -e '\n'"    ${PURPLE}Proceed? [Y/n]${NC} ")" proceed
                    if [ -z "$proceed" ] || [ "$proceed" == "Y" ]; then
                        allDoubleCurrentFiles=$(grep -Pl "$currentFormatted" *)

                        while IFS= read -r file; do
                            sed -Ei 's/'"$currentFormatted"'/'"$new"'/g' "$file"
                            echo "        $file"
                        done <<< "$allDoubleCurrentFiles"
                    fi
                    printf "\n"
                fi
                allDoubleCurrent=${allDoubleCurrent#*$'\n'}

                if [[ ! -z "$updateInterval" ]]; then
                    counter=$(("$counter" + 1))
                    if [[ $(("$counter"%"$updateInterval")) = 0 ]]; then
                        percentage=$(bc -l <<< 'scale=2; '"$counter"'/'"$numberOfDouble"''*100 | sed 's/\.00$//g')
                        echo -ne "    ${YELLOW}$percentage%${NC}\r"
                    fi
                fi
            done <<< "$allDoubleCurrent"
            echo -e "    ${PURPLE}DONE${NC}"
        ;;
    esac
shift
done

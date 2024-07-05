#!/bin/bash

threads=(1)
cache_ratio=(10 50 100)

# Define fixed triplets
triplets=(
    "10 90 0"
    "50 50 0"
    "90 10 0"
    "10 10 80"
)
cache_type=("lru_cache" "hyper_clock_cache")

# Other fixed parameters
num_shard_bits=0
ops_per_thread=1000000
populate_cache=false
value_bytes=$((8))

# Output file
output_file="./cache1.txt"

# Clear the output file
> "$output_file"

# Iterate over each parameter combination and execute the executable file
for triplet in "${triplets[@]}"; do
    for t in "${threads[@]}"; do
        for c in "${cache_ratio[@]}"; do
            for u in "${cache_type[@]}"; do
                # Parse triplet
                insert_percent=$(echo "$triplet" | awk '{print $1}')
                lookup_percent=$(echo "$triplet" | awk '{print $2}')
                erase_percent=$(echo "$triplet" | awk '{print $3}')
                echo "Running with thread=$t, cache_ratio=$c, insert_percent=$insert_percent, lookup_percent=$lookup_percent, erase_percent=$erase_percent, cache_type=$u" | tee -a "$output_file"
                ./release/cache_bench \
                    --threads="$t" \
                    --cache_size="$((c*t*ops_per_thread*insert_percent*value_bytes/10000))" \
                    --num_shard_bits="$num_shard_bits" \
                    --ops_per_thread="$ops_per_thread" \
                    --populate_cache="$populate_cache" \
                    --lookup_insert_percent=0 \
                    --blind_insert_percent=0 \
                    --insert_percent="$insert_percent" \
                    --lookup_percent="$lookup_percent" \
                    --erase_percent="$erase_percent" \
                    --value_bytes="$value_bytes" \
                    --cache_type="$u" | tee -a "$output_file"
                if [ $? -eq 0 ]; then
                    echo "Completed run with thread=$t, cache_ratio=$c, insert_percent=$insert_percent, lookup_percent=$lookup_percent, erase_percent=$erase_percent, cache_type=$u" | tee -a "$output_file"
                else
                    echo "Failed run with thread=$t, cache_size=$c, insert_percent=$insert_percent, lookup_percent=$lookup_percent, erase_percent=$erase_percent, clock_cache=$u" | tee -a "$output_file"
                fi
            done
        done
    done
done

# Add debug information
echo "Script execution completed." | tee -a "$output_file"

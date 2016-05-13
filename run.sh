#!/usr/bin/env bash

# defaults
readonly DEF_NUM_CPUS=1
readonly DEF_PARTITION=debug
readonly DEF_JOB_NAME=povray
readonly DEF_SCENE=sphere
readonly DEF_FRAMES=300
readonly DEF_POVARGS="+A0.01 -J +W1280 +H720"

######

readonly PROGNAME=$(basename $0)
readonly ARGS="$@"

SCENE=$DEF_SCENE
FRAMES=$DEF_FRAMES
POV_ARGS="$DEF_POVARGS"

function usage() {
    cat <<-EOF

 usage: $PROGNAME [-c] [-p] [-J] [-w] [-s] [-f] [-o]

 optional arguments:
    -c: number of CPU cores to request (default: $DEF_NUM_CPUS)
    -p: partition to run job in (default: $DEF_PARTITION)
    -J: job name (default: $DEF_JOB_NAME)
    -s: povray scene (default: $DEF_SCENE)
    -f: number of frames (default: $DEF_FRAMES)
    -o: povray args  (default: $DEF_POVARGS)
    -w: node name

 written by: Jakob Flierl <jakob.flierl@gmail.com>

EOF

    exit 0
}

function parse_options() {
    while getopts ":c:p:J:w:s:f:" opt; do
        case $opt in
            c)
                # make sure -c is passed a valid integer
                if ! [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
                    usage
                fi

                NUM_CPUS=$OPTARG
                ;;
            p)
                PARTITION=$OPTARG
                ;;
            J)
                JOB_NAME=$OPTARG
                ;;
            w)
                NODE_NAME=$OPTARG
                ;;
            s)
                SCENE=$OPTARG
                ;;
            f)
                FRAMES=$OPTARG
                ;;
            o)
                POV_ARGS=$OPTARG
                ;;
            \?|:)
                usage
                ;;
        esac
    done
}

function envsetup() {
    # check to see if user requested a specific number of CPUs
    # ... otherwise use the default
    if [[ -z $NUM_CPUS ]]; then
        NUM_CPUS=$DEF_NUM_CPUS
    fi

    # set the CPU allocation
    SBATCH_OPTS="-n $NUM_CPUS"

    # check for a job name, otherwise use default
    SBATCH_OPTS="$SBATCH_OPTS -J ${JOB_NAME:-$DEF_JOB_NAME}"

    # see if the user specified a partition, otherwise use default
    SBATCH_OPTS="$SBATCH_OPTS -p ${PARTITION:-$DEF_PARTITION}"

    # default time for interactive jobs is 8 hours, ~1 working day
    SBATCH_OPTS="$SBATCH_OPTS -t 8:00:00"

    # if user specifies a node name, run all the tasks in the specified node
    if [[ -n "$NODE_NAME" ]]; then
        SBATCH_OPTS="$SBATCH_OPTS -w ${NODE_NAME} --ntasks-per-node=$NUM_CPUS"
    fi
}

# pass the shell's argument array to the parsing function
parse_options $ARGS

# setup the defaults
envsetup

echo "submitting job $SCENE.pov with $FRAMES frames"

CMD="sbatch --hint=compute_bound $SBATCH_OPTS -O -J $SCENE -a 0-$FRAMES povray.sbatch $SCENE $FRAMES "\'$POV_ARGS\'""

echo " executing: $CMD"

MSG="$($CMD)"

ID=$(echo "$MSG" | awk '{ print $4 }')

JOB=$SCENE-$ID
mkdir -p $JOB
echo "  * created povray job $ID  in `pwd`/$JOB"

echo "#!/usr/bin/env bash" > $JOB/ffmpeg.sbatch
echo "time nice ffmpeg -y -framerate 25 -pattern_type glob -i '*.png' -c:v libx264 -preset veryslow -qp 0 -r 25 -pix_fmt yuv420p ../$SCENE-$ID.mkv" >> $JOB/ffmpeg.sbatch

CMD="sbatch --hint=compute_bound $SBATCH_OPTS --job-name=ffmpeg --depend=afterok:$ID -D $JOB $JOB/ffmpeg.sbatch"

echo " executing: $CMD"

MSG="$($CMD)"

ID=$(echo "$MSG" | awk '{ print $4 }')

echo "  * created ffmpeg job $ID for `pwd`/$JOB"

echo "done"

# EOF

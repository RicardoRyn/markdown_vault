let subj_list: list = [1 2 3]
let current_dir = (pwd)


$subj_list | each { |subj|

    let subj_dir = ($current_dir | path join  ($subj | into string))

    # touch $"($subj_dir)/rm_rjx.txt"
    rm $"($subj_dir)/rm_rjx.txt"

}

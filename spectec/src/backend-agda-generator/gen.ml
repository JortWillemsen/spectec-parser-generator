let gen_string il = Print.string_of_program (Translate.script il)

let gen_file file il =
  let lbnf = gen_string il in
  let oc = Out_channel.open_text file in
  Fun.protect
    (fun () -> Out_channel.output_string oc lbnf)
    ~finally:(fun () -> Out_channel.close oc)

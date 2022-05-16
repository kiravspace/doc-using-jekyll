module Jekyll
  module Tags
    class TreeViewTag < Liquid::Block
      def initialize(tag_name, markup, options)
        super
      end

      def render(context)
        text = super
        template = Liquid::Template.parse(File.read("#{Dir.pwd}/_plugins/templates/test.liquid"))
        template.render('user_name' => 'bob')
      end
    end
  end
end

Liquid::Template.register_tag('treeView', Jekyll::Tags::TreeViewTag)

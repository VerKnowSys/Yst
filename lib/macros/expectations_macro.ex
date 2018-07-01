defmodule ExpectationsMacro do
  @moduledoc """
  ScenarioPlayMacro injects play() function for Scenario
  """


  defmacro __using__(_opts) do
    quote do


      @doc """
      Pipes defined scene expectations to expect() to produce Results
      """
      def check_expectations? scene do
        with  title <- scene.title?,    title_not <- scene.title_not?,
              attr <- scene.attr?,      attr_not <- scene.attr_not?,
              url <- scene.url?,        url_not <- scene.url_not?,
              scrpt <- scene.script?,   scrpt_not <- scene.script_not?,
              src <- scene.src?,        src_not <- scene.src_not?,
              text <- scene.text?,      text_not <- scene.text_not?,
              an_id <- scene.id?,       an_id_not <- scene.id_not?,
              a_class <- scene.class?,  a_class_not <- scene.class_not?,
              a_name <- scene.name?,    a_name_not <- scene.name_not?,
              a_css <- scene.css?,      a_css_not <- scene.css_not?,
              a_tag <- scene.tag?,      a_tag_not <- scene.tag_not?
          do
            expect scene, [
              at_least_single_action: (at_least_single_action scene),
              title: title, title_not: title_not,
              attr: attr, attr_not: attr_not,
              url: url, url_not: url_not,
              script: scrpt, script_not: scrpt_not,
              src: src, src_not: src_not,
              text: text, text_not: text_not,
              id: an_id, id_not: an_id_not,
              class: a_class, class_not: a_class_not,
              name: a_name, name_not: a_name_not,
              css: a_css, css_not: a_css_not,
              tag: a_tag, tag_not: a_tag_not
            ]
        end
      end


      @doc """
      Check expectations
      """
      def expect scene, expectations do
        filtered = expectations |> Enum.filter(fn {_, value} -> value != [] end)
        for expectation <- filtered do
          case expectation do

            {:at_least_single_action, true} ->
              Results.push {:success, scene, "Scene defines at least a single check!"}


            {:at_least_single_action, false} ->
              Results.push {:failure, scene, "Scene lacks any checks!"}


            {:title, entity_list} ->
              for entity <- entity_list do
                if content_matches? page_title(), entity do
                  Results.push {:success, scene, "Title contains element: #{inspect entity}!"}
                else
                  Results.push {:failure, scene, "Title lacks element: #{inspect entity}!"}
                end
              end

            {:title_not, entity_list} ->
              for entity <- entity_list do
                if content_matches? page_title(), entity do
                  Results.push {:failure, scene, "Title contains element: #{inspect entity}!"}
                else
                  Results.push {:success, scene, "Title lacks element: #{inspect entity}!"}
                end
              end


            {:src, entity_list} ->
              for entity <- entity_list do
                if content_matches? page_source(), entity do
                  Results.push {:success, scene, "Elements present in page source: #{inspect entity}!"}
                else
                  Results.push {:failure, scene, "Elements absent in page source: #{inspect entity}!"}
                end
              end

            {:src_not, entity_list} ->
              for entity <- entity_list do
                if content_matches? page_source(), entity do
                  Results.push {:failure, scene, "Elements present in page source: #{inspect entity}!"}
                else
                  Results.push {:success, scene, "Elements absent in page source: #{inspect entity}!"}
                end
              end


            {:text, entity_list} ->
              for entity <- entity_list do
                if content_matches? visible_page_text(), entity do
                  Results.push {:success, scene, "Elements present in page text: #{inspect entity}!"}
                else
                  Results.push {:failure, scene, "Elements absent in page text: #{inspect entity}!"}
                end
              end

            {:text_not, entity_list} ->
              for entity <- entity_list do
                if content_matches? visible_page_text(), entity do
                  Results.push {:failure, scene, "Elements present in page text: #{inspect entity}!"}
                else
                  Results.push {:success, scene, "Elements absent in page text: #{inspect entity}!"}
                end
              end


            {:attr, entity_list} ->
              for {html_entity, attribute, attr_value} <- entity_list do
                for try_html_hook <- @html_elems do
                  if element? try_html_hook, html_entity do
                    case search_element try_html_hook, html_entity do
                      {:ok, element} ->
                        if (attribute_value element, attribute) == attr_value do
                          Results.push {:success, scene, "Found attribute: #{inspect attribute}, value: #{inspect attr_value}!"}
                        else
                          Results.push {:failure, scene, "No attribute: #{inspect attribute}, value: #{inspect attr_value}!"}
                        end

                      {:error, e} ->
                        Logger.error e
                    end
                  end
                end
              end

            {:attr_not, entity_list} ->
              for {html_entity, attribute, attr_value} <- entity_list do
                for try_html_hook <- @html_elems do
                  if element? try_html_hook, html_entity do
                    case search_element try_html_hook, html_entity do
                      {:ok, element} ->
                        if (attribute_value element, attribute) != attr_value do
                          Results.push {:success, scene, "Element with attr: #{inspect attribute}, value: #{attr_value} is absent as expected!"}
                        else
                          Results.push {:failure, scene, "Unexpected element attr: #{inspect attribute}, value: #{attr_value}!"}
                        end

                      {:error, e} ->
                        Logger.error e
                    end
                  end
                end
              end


            {:url, entity_list} ->
              for entity <- entity_list do
                if content_matches? current_url(), entity do
                  Results.push {:success, scene, "URL matches expected: #{inspect entity}!"}
                else
                  Results.push {:failure, scene, "Expected no entry: #{inspect entity} in URL!"}
                end
              end

            {:url_not, entity_list} ->
              for entity <- entity_list do
                if not content_matches? current_url(), entity do
                  Results.push {:success, scene, "Expected no entry: #{inspect entity} in URL!"}
                else
                  Results.push {:failure, scene, "Expected absence of: #{inspect entity} in URL!"}
                end
              end


            {:id, entity_list} ->
              for entity <- entity_list do
                if element? :id, entity do
                  Results.push {:success, scene, "Present element with ID: #{inspect entity}!"}
                else
                  Results.push {:failure, scene, "Absent element with ID: #{inspect entity}!"}
                end
              end

            {:id_not, entity_list} ->
              for entity <- entity_list do
                if element? :id, entity do
                  Results.push {:failure, scene, "Present element with ID: #{inspect entity}!"}
                else
                  Results.push {:success, scene, "Absent element with ID: #{inspect entity}!"}
                end
              end


            {:class, entity_list} ->
              for entity <- entity_list do
                if element? :class, entity do
                  Results.push {:success, scene, "Present element with CLASS: #{inspect entity}!"}
                else
                  Results.push {:failure, scene, "Absent element with CLASS: #{inspect entity}!"}
                end
              end

            {:class_not, entity_list} ->
              for entity <- entity_list do
                if element? :class, entity do
                  Results.push {:failure, scene, "Present element with CLASS: #{inspect entity}!"}
                else
                  Results.push {:success, scene, "Absent element with CLASS: #{inspect entity}!"}
                end
              end


            {:css, entity_list} ->
              for entity <- entity_list do
                if element? :css, entity do
                  Results.push {:success, scene, "Present element with CSS: #{inspect entity}!"}
                else
                  Results.push {:failure, scene, "Absent element with CSS: #{inspect entity}!"}
                end
              end

            {:css_not, entity_list} ->
              for entity <- entity_list do
                if element? :css, entity do
                  Results.push {:failure, scene, "Present element with CSS: #{inspect entity}!"}
                else
                  Results.push {:success, scene, "Absent element with CSS: #{inspect entity}!"}
                end
              end


            {:name, entity_list} ->
              for entity <- entity_list do
                if element? :name, entity do
                  Results.push {:success, scene, "Present element with NAME: #{inspect entity}!"}
                else
                  Results.push {:failure, scene, "Absent element with NAME: #{inspect entity}!"}
                end
              end

            {:name_not, entity_list} ->
              for entity <- entity_list do
                if element? :name, entity do
                  Results.push {:failure, scene, "Present element with NAME: #{inspect entity}!"}
                else
                  Results.push {:success, scene, "Absent element with NAME: #{inspect entity}!"}
                end
              end


            {:tag, entity_list} ->
              for entity <- entity_list do
                if element? :tag, entity do
                  Results.push {:success, scene, "Present TAG: #{inspect entity}!"}
                else
                  Results.push {:failure, scene, "Absent TAG: #{inspect entity}!"}
                end
              end

            {:tag_not, entity_list} ->
              for entity <- entity_list do
                if element? :tag, entity do
                  Results.push {:failure, scene, "Present TAG: #{inspect entity}!"}
                else
                  Results.push {:success, scene, "Absent TAG: #{inspect entity}!"}
                end
              end


            {:script, entity_list} ->
              for entity <- entity_list do
                case execute_script entity do
                  true ->
                    Results.push {:success, scene, "SCRIPT succeeded: #{inspect entity}!"}
                  false ->
                    Results.push {:failure, scene, "SCRIPT failed: #{inspect entity}!"}
                end
              end

            {:script_not, entity_list} ->
              for entity <- entity_list do
                case execute_script entity do
                  true ->
                    Results.push {:failure, scene, "SCRIPT succeeded yet failure expected: #{inspect entity}!"}
                  false ->
                    Results.push {:success, scene, "SCRIPT failed as expected: #{inspect entity}!"}
                end
              end


            undefined ->
              Logger.warn "Undefined expectation: #{inspect expectation}"

          end
        end
      end


    end
  end


end
